module Transactions
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

  def my_transactions ()
    Selenium::WebDriver::Chrome.driver_path="C:/chromedriver_win32/chromedriver1.exe"
    # чтобы наблюдать за запуском браузера и нажатиями в браузере отключить параметр headless
    browser = Watir::Browser.new :chrome, headless: true
    browser.goto 'https://my.fibank.bg/oauth2-server/login?client_id=E_BANK'

    l = browser.link(text: 'English')
    l.exists?
    l.click

    l = browser.link text: 'Demo'
    l.exists?
    l.click
    sleep(2)

    l = browser.link text: 'See all'
    l.exists?
    l.click
    sleep(2)

    l = browser.link text: 'Balance'
    l.exists?
    l.click
    sleep(2)

    l = browser.link(index:1, text: 'Details')
    l.exists?
    l.click
    sleep(2)

    l = browser.element(index: 0, css: "body > div.modal.fade.ng-isolate-scope.modal-521.acc-balance-det.in > div > div > div.modal-body.ng-scope > div.box-border.clearfix.acc-desc-box.ng-scope > div.pull-right.ng-scope > div > a:nth-child(2) > i")
    l.exists?
    l.click
    sleep(2)

    l = browser.i(:class => 'i-triangle-down')
    l.exists?
    l.click

    l = browser.i(:class => ["glyphicon", "glyphicon-chevron-left"])
    l.exists?
    l.double_click
    sleep(2)

    browser.button(:class => ["btn", "btn-default", "btn-sm", "active"]).click
    sleep(2)

    browser.i(:class => ["i-btn-arrow-r", "i-btn-blue-arrow"]).click
    sleep(2)

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
      amount[i] = browser.span(index: i, css: "#step1 > td:nth-child(3) > div > span").text
      i += 1
    end

    $transactions = []
    i = 0
    while i < exit_cond
      user = Transactions.new(date[i], description[i], amount[i], account[23,3], account[0,22])
      hash = {}
      user.instance_variables.each {|var| hash[var.to_s.delete("@")] = user.instance_variable_get(var)}
      $transactions[i] = hash
      i += 1
    end
  end
end
