#this file allows new properties to be created and saved to a database via command line 

require 'open-uri'
require 'mysql'

require_relative 'Property'



#take url from command line
url = ARGV.first
title = ARGV[1].gsub('-space-', ' ')
url = Property.strip_url_prefix(url)
url =~ /(\/.*)/
baseurl = url.gsub($1, '') #remove all first slash and on
baseurl =~ /(.*)\./
baseurl = $1 #removes everything after last period (.com)
baseurl =~ /.*\.(.*)/
baseurl = $1 if $1
puts baseurl

puts 'url is ' + url
url_suffix = Property.create_url_suffix(url, baseurl)
url_suffix_escaped = url_suffix.gsub('/', '-slash-')
url_suffix_escaped = url_suffix_escaped.gsub('#', '-hash-')
#open("http://www.#{url}/").read =~ /<title>(.*?)<\/title>/ #need to catch errors

begin
con = Mysql.new 'localhost', 'root', 'r3dWhite', 'vacation_calendars'
results = Array.new
fail = false
con.query("SELECT id FROM site WHERE name='#{baseurl}'").each_hash {|r| results << r}
if results.nil? || results.first.nil?
  puts "<p class='error'>Error, website '#{baseurl}' is not yet supported</p>"
  fail = true
else
  site_id = results.first['id']
  
  con.query("INSERT INTO properties(title, url, site_id, ics) VALUES('#{title}', '#{url}', '#{site_id}', '#{baseurl + '/' + url_suffix_escaped + '.ics'}')")
  
end


rescue Mysql::Error => e
  puts "<p class='error'>Error! #{e.errno}"
  puts "<p class='error'>#{e.error}</p>"
else
  unless fail
    puts "<p class='sucess'>Added #{url} to database</p>"
  end
ensure
  con.close if con

end