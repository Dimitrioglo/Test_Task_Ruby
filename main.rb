require 'rubygems'
require 'nokogiri'
require 'open-uri'
require 'watir'
require 'selenium-webdriver'
require 'json'
require 'crack'
require 'headless'
require 'colorize'

require_relative 'transactions.rb'
require_relative 'accounts.rb'

include Transactions
include Accounts

#a = Thread.new{Transactions.my_transactions}
#b = Thread.new{Accounts.my_accounts}
#a.join
#b.join

Accounts.my_accounts
Transactions.my_transactions

puts ('***Хэш аккаунтов***').green
puts $account_json
puts ('***Хэш транзакций***').green
puts $transactions

# клонируем accounts, чтобы изменения в accounts не влияло на accountsV1
accountsV1 = Marshal.load(Marshal.dump($account_json))

accountsV1.each do |account|
  # находим подходящие транзакции при помощи фильтрации (.select)
  account['transactions'] = $transactions.select do |transaction|
    transaction['account_name'] === account['name']
  end
end
# записываем полученный json в файл
File.open("save_info.json", "w") do |file|
  file.write(JSON.pretty_generate(accountsV1))
end
