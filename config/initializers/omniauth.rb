Rails.application.config.middleware.use OmniAuth::Builder do
  provider :developer if Rails.env.development? || Rails.env.test?
  provider :google_oauth2, Rails.application.credentials.dig(:oauth, :google, :client_id), Rails.application.credentials.dig(:oauth, :google, :client_secret), {
    scope: 'email,profile'
  }
  provider :seznam_cz, Rails.application.credentials.dig(:oauth, :seznam, :client_id), Rails.application.credentials.dig(:oauth, :seznam, :client_secret)
end
