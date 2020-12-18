
Passwordless.expires_at = lambda { 2.weeks.from_now } # How long until a passwordless session expires.
Passwordless.timeout_at = lambda { 1.hour.from_now } # How long until a magic link expires.

# Passwordless.restrict_token_reuse = true # TODO: Reenable?
Passwordless.default_from_address = "contact@sydevelopers.com"
Passwordless.parent_mailer = 'ApplicationMailer'
Passwordless.redirect_back_after_sign_in = true
Passwordless.success_redirect_path = '/cms'
Passwordless.failure_redirect_path = '/managers/sign_in'
Passwordless.sign_out_redirect_path = '/'
