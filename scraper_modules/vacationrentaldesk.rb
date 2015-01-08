module Vacationrentaldesk

  def scrape
    p 'scraping...  from Vacationrentaldesk'
    
    noko = Nokogiri::HTML(@b.html)
    options = noko.search('option')
    mname = options.first.content
    options.each do |month|
      mname = month.content
      nokotwo = Nokogiri::HTML(@b.html)
      @b.link(:text, 'Next Month').click
      table = nokotwo.search('table')
      table = table.first.to_html
      tb = Nokogiri::HTML(table)
      tb = tb.css('td.largeCalSelectedDayStyle')
      tb.each do |tb|
        slop = Nokogiri::Slop(tb.to_html)
        slop.content =~ /\A([1-9][1-9]?)/
        date = $1
        puts "date would be #{slop.content} #{mname} 0:00"
        @unavail_dates.push(DateTime.parse(date + " " + mname + " 0:00"))
      end
    end

    @b.close
    puts 'complete'
  end
  
end