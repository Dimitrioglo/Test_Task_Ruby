require 'rubygems'
require 'nokogiri'
require 'open-uri'
require 'watir'
require 'selenium-webdriver'
require 'json'
require 'crack'
require 'headless'
require 'colorize'

class Accounts
  attr_accessor :name, :balance, :currency, :nature

  def initialize(name, balance, currency, nature)
    @name = name.chomp(' >') # оставил потому что это мой ключ для селекта и сравниваю с элементом у которого нет знака >
    @balance = balance
    @currency = currency
    @nature = nature
  end

  def to_hash
    {
    name: @name,
    balance: @balance,
    currency: @currency,
    nature: @nature
    }
  end
end

class Transactions
  attr_accessor :date, :description, :amount, :currency, :account_name

  def initialize(date, description, amount, currency, account_name)
    @date = date
    @description = description
    @amount = amount
    @currency = currency
    @account_name = account_name
  end

  def to_hash
    {
    date: @date,
    description: @description,
    amount: @amount,
    currency: @currency,
    account_name: @account_name
    }
  end
end

$URL = 'https://my.fibank.bg/oauth2-server/login?client_id=E_BANK'

class Fibank
  def my_accounts
    Selenium::WebDriver::Chrome.driver_path="C:/chromedriver_win32/chromedriver1.exe"
    # чтобы наблюдать за запуском браузера и нажатиями в браузере отключить параметр headless
    $browser = Watir::Browser.new :chrome, headless: true
    $browser.goto $URL

    l = $browser.link text: 'English'
    l.exists?
    l.click

    l = $browser.link text: 'Demo'
    l.exists?
    l.click
    sleep 2

    l = $browser.link text: 'See all'
    l.exists?
    l.click
    sleep 2

    l = $browser.link text: 'Balance'
    l.exists?
    l.click
    sleep 1
    # счетчик количества аккаунтов
    $exit_condition = $browser.span(css: "#main_grid > div > div:nth-child(2) > div:nth-child(2) > div > div > div > span").text.to_i

    def get_array(name_array, selector)
      var = 0
      while var < $exit_condition
        name_array[var] = $browser.element(index: var, css: selector).text.strip
        var += 1
      end
    end

    # получаем массивы данных
    get_array(name = [], "#step2 > div > div.blue-bg.h-68 > a")
    get_array(currency = [], "#step2 > div > div:nth-child(3) > div:nth-child(5) > span")
    get_array(cur_balance = [], "#step2 > div > div:nth-child(3) > div:nth-child(2) > span")

    i = 0
    $account_json = []
    while i < $exit_condition
      user = Accounts.new(name[i], cur_balance[i].to_f, currency[i], 'checking')
      hash = {}
      user.instance_variables.each { |var| hash[var.to_s.delete("@")] = user.instance_variable_get(var) }
      $account_json[i] = hash
    #  $account_json[i] = to_hash() остановился здесь не видит метод to_hash
      i += 1
    end
  end

  def my_transactions
    Selenium::WebDriver::Chrome.driver_path="C:/chromedriver_win32/chromedriver1.exe"
    # чтобы наблюдать за запуском браузера и нажатиями в браузере отключить параметр headless
    browser = Watir::Browser.new :chrome, headless: true
    browser.goto $URL

    l = browser.link text: 'English'
    l.exists?
    l.click

    l = browser.link text: 'Demo'
    l.exists?
    l.click
    sleep 2

    l = browser.link text: 'See all'
    l.exists?
    l.click
    sleep 2

    l = browser.link text: 'Balance'
    l.exists?
    l.click
    sleep 2

    l = browser.link(index:1, text: 'Details')
    l.exists?
    l.click
    sleep 2

    l = browser.element(index: 0, css: "body > div.modal.fade.ng-isolate-scope.modal-521.acc-balance-det.in > div > div > div.modal-body.ng-scope > div.box-border.clearfix.acc-desc-box.ng-scope > div.pull-right.ng-scope > div > a:nth-child(2) > i")
    l.exists?
    l.click
    sleep 2

    l = browser.i(:class => 'i-triangle-down')
    l.exists?
    l.click

    l = browser.i(:class => ["glyphicon", "glyphicon-chevron-left"])
    l.exists?
    l.double_click
    sleep 2

    browser.button(:class => ["btn", "btn-default", "btn-sm", "active"]).click
    sleep 2

    browser.i(:class => ["i-btn-arrow-r", "i-btn-blue-arrow"]).click
    sleep 2

    # счетчик количества аккаунтов
    exit_cond = browser.span(:class => ["blue-txt", "bold", "ng-binding", "ng-scope"]).text.to_i
    account = browser.span(:class => ["filter-option"]).text

    date = []
    description = []
    amount = []
    currency = []
    account_name = []

    i = 0
    while i < exit_cond
      date[i] = browser.div(index: i, :class => ["text-center", "first-cell", "cellText", "ng-scope"]).text
      description[i] = browser.p(index: i + 2, :class => ["ng-scope"]).text
      i += 1
      amount[i] = browser.span(index: i, css: "#step1 > td:nth-child(3) > div > span").text
    end

    $transactions = []
    i = 0
    while i < exit_cond
      user = Transactions.new(date[i], description[i], amount[i].to_f, account[23,3], account[0,22])
      hash = {}
      user.instance_variables.each {|var| hash[var.to_s.delete("@")] = user.instance_variable_get(var)}
      $transactions[i] = hash
      i += 1
    end
  end
end

Fibank.new.my_accounts
Fibank.new.my_transactions

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
