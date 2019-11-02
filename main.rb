require 'open-uri'
require 'nokogiri'

doc = Nokogiri::HTML(open('https://my.fibank.bg/oauth2-server/login?client_id=E_BANK'))

puts doc
