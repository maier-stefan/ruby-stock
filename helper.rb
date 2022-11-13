def has_stock?(body)
  body.include?('<input type="number"') &&
  body.include?("addToCartButton") &&
  !body.match(/<button type="submit".*.disabled.*.addToCartButton/m)
end

def fetch(uri_str, limit = 10)
  raise ArgumentError, "HTTP redirect too deep" if limit == 0

  uri = URI(uri_str)
  res = Net::HTTP.get_response(uri)

  case res.code
  when Net::HTTPRedirection
    fetch(res["location"], limit - 1)
  when "301"
    location = res["location"]

    if location.split("/").size == 2
      url = URI.join(uri_str, "/").to_s
      url_full = url + location[1...]

      location = url_full
    end

    fetch(location, limit - 1)
  else
    res
  end
end

def stock_for_url(url)
  res = fetch(url)
  has_stock?(res.body) ? "in stock" : "out of stock"
end
