Passwordless.configure do |config|
  config.expires_at = lambda { 2.weeks.from_now } # How long until a passwordless session expires.
  config.timeout_at = lambda { 1.day.from_now } # How long until a magic link expires.

  config.restrict_token_reuse = false # Allow login links to be used multiple times within timeout
  config.default_from_address = 'Sahaj Atlas <contact@sydevelopers.com>'
  config.parent_mailer = 'ApplicationMailer'
  config.redirect_back_after_sign_in = true
  config.success_redirect_path = '/cms'
  config.failure_redirect_path = '/managers/sign_in'
  config.sign_out_redirect_path = '/'
end