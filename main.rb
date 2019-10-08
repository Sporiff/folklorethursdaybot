require 'elephrame'
require 'open-uri'
require 'nokogiri'
require 'httparty'
require 'rss'
require 'date'

folkloreThursday = Elephrame::Bots::Periodic.new '10s'
runDates = ["2018-10-08T00:38:47+01:00"]

folkloreThursday.run do |bot|

  data = Hash.new

  response = HTTParty.get 'https://folklorethursday.com/feed'

  feed = RSS::Parser.parse response.body

  feed.items.each do |item|
    if (DateTime.parse "#{item.pubDate}") > (DateTime.parse runDates[-1].to_s)
      data ["#{item.title}"] = "#{item.link}"
    else
      break
    end
  end
  puts data
  puts runDates
  
  data.each do |key, value|
    bot.post("#{key} \n \n #{value} \n #folklorethursday")
  end
  
  runDates.push [DateTime.now]
  data.clear

end