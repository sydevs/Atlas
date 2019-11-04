Passwordless.timeout_at = -> { 2.hours.from_now }
Passwordless.expires_at = -> { 1.week.from_now }
Passwordless.restrict_token_reuse = true
