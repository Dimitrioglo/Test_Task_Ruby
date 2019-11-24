require 'rubygems'
require 'nokogiri'
require 'open-uri'
require 'watir'
require 'selenium-webdriver'
require 'json'
require "crack"

Selenium::WebDriver::Chrome.driver_path="C:/chromedriver_win32/chromedriver1.exe"

b = Watir::Browser.new
b.goto 'https://my.fibank.bg/oauth2-server/login?client_id=E_BANK'

l = b.link text: 'English'
l.exists?
l.click

l = b.link text: 'Demo'
l.exists?
l.click

sleep(2)
l = b.link text: 'See all'
l.exists?
l.click

sleep(4)

XML_CODE = Nokogiri::XML(open("https://my.fibank.bg/EBank/accounts/summ"))
puts XML_CODE  # => Nokogiri::HTML::Document

File.open("blossom.xml", "a") do |file|
  file.write(XML_CODE)
end

myXML  = Crack::XML.parse(File.read("blossom.xml"))
myJSON = myXML.to_json

puts myJSON

File.open("xml2json.json", "a") do |file|
  file.write(myJSON)
end
