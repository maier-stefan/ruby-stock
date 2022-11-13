require "uri"
require "net/http"
require "rubyXL"
require "./helper"

workbook = RubyXL::Parser.parse("stocks.xlsx")
worksheet = workbook[0]

urls = []

worksheet.each_with_index do |item, index|
  if index == 0
    next
  end

  for i in 0...9
    if item[i].value.nil?
      next
    end

    urls << item[i].value
  end
end

limit_urls = 50
result = {}

puts "urls", urls

urls.each do |url|
  puts url
  result[url] = stock_for_url(url)
  if limit_urls == 0
    break
  end

  limit_urls -= 1
end

puts result
