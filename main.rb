require 'rubygems'
require 'nokogiri'
require 'open-uri'
require 'watir'
require 'selenium-webdriver'
require 'json'
require 'pry'
require 'headless'
require 'colorize'


class Transactions
  attr_accessor :date, :description, :amount, :currency, :account_name

  def initialize(date, description, amount, currency, account_name)
    @date = date
    @description = description
    @amount = amount
    @currency = currency
    @account_name = account_name
  end
end

class Accounts
  attr_accessor :name, :balance, :currency, :nature

  def initialize(name, balance, currency, nature)
    @name = name.chomp(' >') # оставил потому что это мой ключ для селекта и сравниваю с элементом у которого нет знака >
    @balance = balance
    @currency = currency
    @nature = nature
  end
end

class Fibank
  def execute
    connect
    fetch_accounts
    connect
    fetch_transactions
    print_data
  end

  URL = 'https://my.fibank.bg/oauth2-server/login?client_id=E_BANK'

  def connect
    Selenium::WebDriver::Chrome.driver_path="C:/chromedriver_win32/chromedriver1.exe"
    # чтобы наблюдать за запуском браузера и нажатиями в браузере отключить параметр headless
    $browser = Watir::Browser.new :chrome, headless: true
    $browser.goto URL
    $browser.link(text: 'English').wait_until_present.click
    $browser.link(text: 'Demo').wait_until_present.click
    sleep 2
    $browser.link(text: 'See all').wait_until_present.click
    sleep 2
    $browser.link(text: 'Balance').wait_until_present.click
    sleep 2
  end

  def fetch_accounts
    # счетчик количества аккаунтов
    $exit_condition = Nokogiri::HTML.fragment($browser.span(class: ["blue-txt", "bold", "ng-binding"]).html).text.to_i
    #$exit_condition = $browser.span(c  ss: "#main_grid > div > div:nth-child(2) > div:nth-child(2) > div > div > div > span").text.to_i

    def get_array(name_array, selector)
      var = 0
      while var < $exit_condition
        name_array[var] = $browser.element(index: var, css: selector).text.strip
        var += 1
      end
    end

    # вот я достал outerHTML так же как и раньше но только уже не значение а полностью кусок html
    html = Nokogiri::HTML.fragment($browser.element(index: 0, css: "#step2 > div > div.blue-bg.h-68 > a").html)
    puts html
    # ниже значение html
    #<a class="white-txt ellipsis-txt ng-binding" ui-sref='app.layout.ACCOUNTS.DETAILS.{IBAN}({iban: "BG10FINV91501003939179"})' href="/EBank/accounts/details/BG10FINV91501003939179">BG10FINV91501003939179
    #&gt;</a>
    # как с помощью с твоего примера мне получить значение BG10FINV91501003939179? Не нахожу способа как к нему обратиться
    #
    # def parse_accounts(html)
    #     html.css('table#Example tr').each do |tr|
    #     name = tr.at_css('span.example-class').text
    #     ...
    #
    #     @accounts << Account.new(name, ...)
    #   end
    # end

    puts '*пробовал так значение ниже*'
    #puts html.css('a.ellipsis-txt')
    #puts html.css('a').first
    puts '***значение выше***********'

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
      i += 1
    end
  end

  def fetch_transactions

    $browser.link(index:1, text: 'Details').wait_until_present.click
    sleep 2
    $browser.element(index: 0, css: "body > div.modal.fade.ng-isolate-scope.modal-521.acc-balance-det.in > div > div > div.modal-body.ng-scope > div.box-border.clearfix.acc-desc-box.ng-scope > div.pull-right.ng-scope > div > a:nth-child(2) > i").wait_until_present.click
    sleep 2
    $browser.i(:class => 'i-triangle-down').wait_until_present.click
    sleep 2
    $browser.i(:class => ["glyphicon", "glyphicon-chevron-left"]).wait_until_present.double_click
    sleep 2
    $browser.button(:class => ["btn", "btn-default", "btn-sm", "active"]).click
    sleep 2
    $browser.i(:class => ["i-btn-arrow-r", "i-btn-blue-arrow"]).click
    sleep 2

    # счетчик количества аккаунтов
    exit_cond = $browser.span(:class => ["blue-txt", "bold", "ng-binding", "ng-scope"]).text.to_i
    account = $browser.span(:class => ["filter-option"]).text

    date = []
    description = []
    amount = []
    currency = []
    account_name = []

    i = 0
    while i < exit_cond
      date[i] = $browser.div(index: i, :class => ["text-center", "first-cell", "cellText", "ng-scope"]).text
      description[i] = $browser.p(index: i + 2, :class => ["ng-scope"]).text
      i += 1
      amount[i] = $browser.span(index: i, css: "#step1 > td:nth-child(3) > div > span").text
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

  def print_data
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
    puts ('***данные в формате JSON***').green
    puts JSON.pretty_generate(accountsV1)
  end
end

Fibank.new.execute
