require 'sentry-rails'

Sentry.init do |config|
  config.dsn = 'https://c4e7fa2612fac6a0681ad6950603a4cb@o4508367956738048.ingest.de.sentry.io/4508367960146000'
  config.breadcrumbs_logger = [:active_support_logger, :http_logger]

  # Set traces_sample_rate to 1.0 to capture 100%
  # of transactions for tracing.
  # We recommend adjusting this value in production.
  config.traces_sample_rate = 1.0
  # or
  config.traces_sampler = lambda do |context|
    true
  end
  
  # Set profiles_sample_rate to profile 100%
  # of sampled transactions.
  # We recommend adjusting this value in production.
  config.profiles_sample_rate = 1.0
end