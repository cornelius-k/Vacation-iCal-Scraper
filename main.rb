require 'headless'
require 'watir-webdriver'
require 'nokogiri'
require 'active_support/core_ext'
require 'mysql'

require_relative 'Property'

#db config
#todo: parse env vars or config file for db credentials
db = { 
  hostname: 'localhost',
  username: 'user',
  password: 'pass',
  db_name: 'vacation_calendars',
  table_name: 'properties'}


#start headless for webdriver
headless = Headless.new
headless.start

#run create_calendar() on each property record in the database
con = Mysql.new db[:hostname], db[:username], db[:password], db[:db_name]
query = con.query("SELECT * FROM #{db[:table_name]}")
rows = Array.new
query.each_hash {|r| rows << r}
rows.each do |row|
  status = 0
  if create_calendar(row['url'])
    status = 1 #if successful
  end
  con.query("UPDATE `properties` SET status=#{status} where id=#{row['id']}")
end

#close headless
headless.destroy

#creates a property object from a string url and then does the majority of the work
def create_calendar(url)
  property = Property.new(url)
  property.launch
  property.scrape
  property.create_ranges
  property.create_cal
  property.save_cal
  return 1;
end