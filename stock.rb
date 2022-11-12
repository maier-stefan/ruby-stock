require 'uri'
require 'net/http'
require 'rubyXL'
require 'resolv-replace'

workbook = RubyXL::Parser.parse("stocks.xlsx")
worksheet = workbook[0]

limit_urls = 50

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

def fetch(uri_str, limit = 10)
    raise ArgumentError, 'HTTP redirect too deep' if limit == 0

    uri = URI(uri_str)
    res = Net::HTTP.get_response(uri)

    case res.code
    when "200" then 
        res
    when Net::HTTPRedirection then 
        fetch(res['location'], limit - 1)
    when "301" then
        location = res['location']

        if location.split("/").size == 2
            url = URI.join(uri_str, "/").to_s
            url_full = url + location[1...]

            location = url_full
        end

        fetch(location, limit - 1)
    end
end

result = {}

urls.each do |url|
    puts url
    res = fetch(url) 

    case res
    when Net::HTTPSuccess then
        if res.body.include? '<input type="number"'
            if res.body.match /<button type="submit".*.disabled.*.addToCartButton/m
                result[url] = "out of stock"
            else
                result[url] = "stock"
            end
        else
            result[url] = "out of stock"
        end
    else
        result[url] = "out of stock"  
    end


    if limit_urls == 0
        break
    end

    limit_urls -= 1
end

puts result