require 'capybara/rails'
require 'capybara/rspec'
require 'selenium-webdriver'

# Register Chrome driver
Capybara.register_driver :selenium_chrome do |app|
  Capybara::Selenium::Driver.new(app, browser: :chrome)
end

# Register headless Chrome driver
Capybara.register_driver :selenium_chrome_headless do |app|
  options = Selenium::WebDriver::Chrome::Options.new
  options.add_argument('--headless')
  options.add_argument('--no-sandbox')

  Capybara::Selenium::Driver.new(app, browser: :chrome, options: options)
end

# Set JavaScript driver for feature specs with js: true
Capybara.javascript_driver = :selenium_chrome_headless
Capybara.default_driver = :rack_test
Capybara.server = :puma, { Silent: true }
