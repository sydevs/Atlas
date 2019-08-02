require 'bigdecimal'
require 'net/http'
require 'json'
require 'erb'
include ERB::Util

# This script is used to process a CSV of addresses and output the addresses with latlong values attached.
# The script uses the Nominatim API, so be careful to not run the script too many times, as you will hit bandwidth limits.

def valid_coordinate? string
  string.include?('.') && !!BigDecimal(string)
rescue
  return false
end

def geocode address, country
  address = address.split(', ').map(&:strip)
  if valid_coordinate?(address.last)
    puts "[X] Skipping #{address}"
    return
  end

  postcode = url_encode(address.last)
  country = url_encode(country)

  url = URI("https://nominatim.openstreetmap.org/search/?postalcode=#{postcode}&country=#{country}&format=jsonv2")
  puts "[?] Getting #{url}"
  response = Net::HTTP.get(url)
  data = JSON.parse(response)

  if data.length > 0
    return "#{data[0]['lat']}, #{data[0]['lon']}"
  else
    puts "[X] Couldn't find #{address}"
  end
end

def process_file file, country
  puts "Processing #{file} for #{country}"
  output = ''

  url = File.join(File.dirname(__FILE__), "raw.#{file}")
  File.open(url, 'r').each do |line|
    latlong = geocode(line, country)
    output += "#{line.strip}, #{latlong}\n" if latlong
  end

  puts output

  url = File.join(File.dirname(__FILE__), file)
  File.open(url, 'w') do |f|
    f.puts output
  end
end

process_file 'uk.addresses.txt', 'UK'
process_file 'us.addresses.txt', 'USA'
