require 'icalendar'
require 'active_support/time'
require 'fileutils'

include Icalendar

# Instances of the Property class are created with only a url string parameter
# from which a base url is determined and used to dynamically load a module 
# which is eval'd to extend Property on the fly.
# This is advantageous in some situations, but if you are running this from a 
# public machine you may want to consider possible security risks.
class Property
  attr_accessor :cal, :ranges
  
  #url normalization
  def self.strip_url_prefix(url)
    if url.start_with?('http://')
      url = url.gsub('http://', "")
    end
    if url.start_with?('www.')
      url = url.gsub('www.', "")
    end
    return url
    
  end
  
  def self.create_url_suffix(url, baseurl)
    p 'running create url suffix...'
    url_suffix = url.gsub(baseurl, "") #remove baseurl, result string is .com/xxx
    url_suffix = url_suffix.strip #remove whitespace
    url_suffix =~ /(.*?)\/*\z/ #remove possible trailing slash
    url_suffix = $1
    url_suffix =~ /\A\.?.*?\/(.*)/ #remove leading .com/org/etc and remove slash, result string is xxx
    if $1 
      url_suffix = $1
    else 
      url_suffix = url_suffix.insert(0, baseurl)
    end
    url_suffix = self.strip_url_prefix(url_suffix)    
    return url_suffix
  end
    
  def initialize(url)
    p 'initializing Instance...   '
    @ranges = Array.new
    @unavail_dates = Array.new
    @url = url
    @url = self.class.strip_url_prefix(@url)
    @url =~ /(\/.*)/
    @baseurl = @url.gsub($1, '')
    @baseurl =~ /(.*)\./
    @baseurl = $1 #removes everything after last period (.com)
    @baseurl =~ /.*\.(.*)/ 
    @baseurl = $1 if $1 #removes subdomains
    @url_suffix = self.class.create_url_suffix(@url, @baseurl)
    @url_suffix_escaped = @url_suffix.gsub('/', '-slash-') #take slashes out of filename and repalace with -slash-
    @url_suffix_escaped = @url_suffix_escaped.gsub('#', '-hash-')
    require_relative 'scraper_modules/' + @baseurl
    eval "extend #{@baseurl.capitalize}"
    @cal = Calendar.new
    file_location = @baseurl
    puts 'complete'
    self
  end
  
  #launches WATIR web browser
  def launch
    p 'launching...   '
    @b = Watir::Browser.new :chrome
    @b.goto(@url)
    puts 'complete'
  end
  
  #creates a range of dates that a property is unavailable
  def create_ranges
    i = 0 
    @ranges[i] = (@unavail_dates.first..@unavail_dates.first.yesterday)
    @unavail_dates.each do |unavail_date|
      if (unavail_date == @ranges[i].last.tomorrow)
        @ranges[i] = (@ranges[i].first..unavail_date)
      else 
        i = i + 1
        @ranges[i] = (unavail_date..unavail_date)
      end
    end
  end
  
  #creates iCal calendar file
  def create_cal
    p 'creating calendar...   '
    @ranges.each do |range|
      check_in = range.first.yesterday
      check_in = check_in.change(hour: 15)
      check_out = range.last.tomorrow
      check_out = check_out.change(hour: 11)
      event = Event.new
      event.start = check_in
      event.end = check_out
      event.summary = "Unavailable"
      @cal.add_event(event)
    end
    puts 'complete'
  end
  
  #saves calendar file to filesystem inside calendar_files/
  def save_cal
    p 'saving...   '
    ics = @cal.to_ical
    FileUtils.mkdir('calendar_files/' + @baseurl) unless File.exists?('calendar_files/' + @baseurl)
    File.open('calendar_files/' + @baseurl + "/" + @url_suffix_escaped + ".ics", 'w') {|f| f.write(ics) }
    puts 'complete'
    puts 'file saved at calendar_files/' + @baseurl + '/' + @url_suffix_escaped + '.ics'
  end
    
end

