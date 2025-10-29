return unless defined?(Sentry)

Sentry.init do |config|
  config.breadcrumbs_logger = [:active_support_logger, :http_logger]
  config.send_default_pii = true
  config.dsn = Rails.application.credentials[:sentry_dsn]
  config.traces_sample_rate = 1.0
  config.enabled_environments = %w[production]
  config.enable_logs = true
  config.enabled_patches = [:logger]
end
