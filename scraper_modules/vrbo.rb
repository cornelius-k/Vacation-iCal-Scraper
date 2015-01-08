module Vrbo

  def scrape
    p 'scraping...   '
    noko = Nokogiri::HTML(@b.html)
    divs = noko.css('div.cal-months div.calmonth')
    month_divs = Array.new
    divs.each do |div|
      month_divs << Nokogiri::Slop(div.to_html()) if (month_divs.size < 6)
    end
    
    month_divs.each do |eachmd|
      mname = eachmd.div.h3.content
      strikes = eachmd.div.table.tbody.tr.to_html.scan((/<strike>(.*)<\/strike>/))
      
      strikes.each do |each|
        @unavail_dates.push(DateTime.parse(each.first + " " + mname + " 0:00"))
      end
      
    end
    @b.close
    puts 'complete'
  end
  
end