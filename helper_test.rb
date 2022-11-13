require "minitest/autorun"
require "vcr"
require "webmock"
require "./helper"

VCR.configure do |c|
  c.cassette_library_dir = "mocks/cassettes"
  c.before_http_request do |request|
    VCR.insert_cassette(request.uri)
  end
  c.after_http_request do |request|
    VCR.eject_cassette
  end
  c.hook_into :webmock
end

describe "stock_for_url test case" do
  it "tests in stock for url" do
    url = "https://www.foodspring.de/protein-balls-12-paket"
    assert_equal stock_for_url(url), "in stock"
  end

  it "tests out of stock for url with empty body" do
    url = "https://www.foodspring.at/bio-coconut-chips-6-paket"
    assert_equal stock_for_url(url), "out of stock"
  end

  it "tests out of stock for de url" do
    url = "https://www.foodspring.de/bio-coconut-chips-6-paket"
    assert_equal stock_for_url(url), "out of stock"
  end
end

describe "has_stock test case" do
  it "tests for empty body" do
    assert_equal has_stock?(""), false
  end

  it "tests on stocks overview" do
    html_string = File.read("./mocks/htmls/snacks_overview.html")
    assert_equal has_stock?(html_string), false
  end

  it "tests on product page" do
    html_string = File.read("./mocks/htmls/product_in_stock.html")
    assert_equal has_stock?(html_string), true
  end

  it "tests on product page disbaled button" do
    html_string = File.read("./mocks/htmls/product_out_stock.html")
    assert_equal has_stock?(html_string), false
  end
end
