require 'rubygems'
require 'nokogiri'
require 'open-uri'
require 'watir'
require 'selenium-webdriver'
require 'json'
require "crack"

Selenium::WebDriver::Chrome.driver_path="C:/chromedriver_win32/chromedriver1.exe"

$browser = Watir::Browser.new
$browser.goto 'https://my.fibank.bg/oauth2-server/login?client_id=E_BANK'

l = $browser.link text: 'English'
l.exists?
l.click

l = $browser.link text: 'Demo'
l.exists?
l.click

sleep(2)

l = $browser.link text: 'See all'
l.exists?
l.click

sleep(2)
$browser.hidden(css: "#app > div > div.container.ng-scope > div.layout-content-col > div:nth-child(4) > div > div.ng-scope > div > ul > li.ng-scope.activ > a").click
sleep(2)
l = $browser.links.collect(&:text)
puts l
