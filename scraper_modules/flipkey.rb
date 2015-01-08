module Flipkey

  def scrape
    p 'scraping...  from Flipkey'
    noko = Nokogiri::HTML(@b.html)
    divs = noko.css('div#rate-tab-availability div div.calendar')
    month_divs = Array.new
    divs.each do |div|
      month_divs << Nokogiri::Slop(div.to_html())
    end
    
    month_divs.each do |eachmd|
      mname = eachmd.content
      mname = mname.strip
      mname =~ /(.*)$/
      mname = $1
      strikes = eachmd.to_html.scan((/class="na">(.*)<\/td>/))
      strikes.each do |each|
        @unavail_dates.push(DateTime.parse(each.first + " " + mname + " 0:00"))
      end
      
    end
    @b.close
    puts 'complete'
  end
  
end