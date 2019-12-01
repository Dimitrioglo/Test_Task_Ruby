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

l = $browser.link text: 'Balance'
l.exists?
l.click

def get_array(index, name_array, selector)
  var = 0
  while var < index
    name_array[var] = $browser.element(index: var, css: selector).text.strip
    var += 1
  end
end

get_array(2, name = [], "#step2 > div > div.blue-bg.h-68 > a" )
puts name
get_array(2, currency = [], "#step2 > div > div:nth-child(3) > div:nth-child(5) > span" )
puts currency
get_array(2, cur_balance = [], "#step2 > div > div:nth-child(3) > div:nth-child(2) > span" )
puts cur_balance

class Accounts
  attr_accessor :name, :balance, :currency , :nature

  def initialize(name, balance, currency, nature)
    @name = name.chomp(' >')
    @balance = balance
    @currency = currency
    @nature = nature
  end

  def as_json(options={})
    {
      name: @name,
      balance: @balance,
      currency: @currency,
      nature: @nature
    }
  end

  def to_json(*options)
    as_json(*options).to_json(*options)
  end
end

i = 0
while i < 2
  user = Accounts.new(name[i], currency[i], cur_balance[i], 'checking')
  h = {:"account#{i+1}"=> user}
  puts JSON.pretty_generate(h)
  i += 1
end
