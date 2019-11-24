require 'rubygems'
require 'nokogiri'
require 'open-uri'

page = Nokogiri::HTML(open("https://my.fibank.bg/EBank/accounts/summ"))
puts page   # => Nokogiri::HTML::Document
