require 'elephrame'
require 'open-uri'
require 'httparty'
require 'rss'
require 'date'

# Set the bot to run once an hour every Thursday

folkloreThursday = Elephrame::Bots::Periodic.new '0 10-22 * * 4'

# Run the bot

folkloreThursday.run do |bot|
  
  # Read the last run date from a file. This is so that the
  # run dates don't change even if the server is rebooted
  
  runDates = File.read("./runDates.txt")
  
  # Declare a hash in which to store the values from the XML

  data = Hash.new

  # Download the RSS file from the website

  response = HTTParty.get 'https://folklorethursday.com/feed'

  # Parse the file to easily read the items

  feed = RSS::Parser.parse response.body

  # For each item, check that its published date is greater than the last run date and
  # store the title and link from each entry to the data hash

  feed.items.each do |item|
    if (DateTime.parse "#{item.pubDate}") > (DateTime.parse runDates)
      data ["#{item.title}"] = "#{item.link}"
    else
      break
    end
  end

  # For each item added to the hash, create new post

  data.each do |key, value|
    bot.post("#{key} \n \n #{value} \n #folklorethursday")
  end

  # Overwrite the timing file with the new last run date to prevent
  # double posting

  File.open("runDates.txt", "w+"){ |file| file.puts DateTime.now.to_s}
  
  # Clear the data from the hash for neatness
  
  data.clear

end