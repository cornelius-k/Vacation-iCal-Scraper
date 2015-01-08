module Homeaway

  def scrape
    p 'scraping...  from Homeaway '
    noko = Nokogiri::HTML(@b.html)
    divs = noko.css('div#calendars div.month table')
    month_divs = Array.new
    divs.each do |div|
      month_divs << Nokogiri::Slop(div.to_html())
    end
    
    month_divs.each do |eachmd|
      mname = eachmd.table.thead.content
      mname = mname.strip
      mname =~ /(.*)$/
      mname = $1
      strikes = eachmd.to_html.scan((/class="u">(.*)<\/td>/))
      strikes.each do |each|
        @unavail_dates.push(DateTime.parse(each.first + " " + mname + " 0:00"))
      end
      
    end
    @b.close
    puts 'complete'
  end
  
end