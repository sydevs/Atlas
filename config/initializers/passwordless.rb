Passwordless.timeout_at = -> { 2.hours.from_now }
Passwordless.expires_at = -> { 1.week.from_now }
Passwordless.restrict_token_reuse = true
Passwordless.redirect_back_after_sign_in = true
Passwordless.sign_out_redirect_path = '/'
Passwordless.failure_redirect_path = '/managers/sign_in'
Passwordless.success_redirect_path = '/cms/home'
