Mailjet.configure do |config|
  config.api_key = Rails.application.credentials.dig(:mailjet, :api_key)
  config.secret_key = Rails.application.credentials.dig(:mailjet, :secret_key)
  config.api_version = 'v3.1'
  config.default_from = 'magnusekm@gmail.com'
end
