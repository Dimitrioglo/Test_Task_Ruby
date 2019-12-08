module Accounts
  class Accounts
    attr_accessor :name, :balance, :currency, :nature

    def initialize(name, balance, currency, nature)
      @name = name.chomp(' >')
      @balance = balance
      @currency = currency
      @nature = nature
    end
  end

  def my_accounts
    Selenium::WebDriver::Chrome.driver_path="C:/chromedriver_win32/chromedriver1.exe"
    # чтобы наблюдать за запуском браузера и нажатиями в браузере отключить параметр headless
    $browser = Watir::Browser.new :chrome, headless: true
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
    sleep(1)
    # счетчик количества аккаунтов
    $exit_condition = $browser.span(css: "#main_grid > div > div:nth-child(2) > div:nth-child(2) > div > div > div > span").text.to_i

    def get_array(name_array, selector)
      var = 0
      while var < $exit_condition
        name_array[var] = $browser.element(index: var, css: selector).text.strip
        var += 1
      end
    end

    #получаем массивы данных
    get_array(name = [], "#step2 > div > div.blue-bg.h-68 > a")
    get_array(currency = [], "#step2 > div > div:nth-child(3) > div:nth-child(5) > span")
    get_array(cur_balance = [], "#step2 > div > div:nth-child(3) > div:nth-child(2) > span")

    i = 0
    $account_json = []
    while i < $exit_condition
      user = Accounts.new(name[i], currency[i], cur_balance[i], 'checking')
      hash = {}
      user.instance_variables.each { |var| hash[var.to_s.delete("@")] = user.instance_variable_get(var) }
      $account_json[i] = hash
      i += 1
    end
  end
end
