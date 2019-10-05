
Rails.application.configure do
  ActionMailer::Base.delivery_method = :smtp
  ActionMailer::Base.smtp_settings = {
    address: 'smtp.gmail.com',
    port: 587,
    user_name: ENV['SMTP_EMAIL'],
    password: ENV['SMTP_PASSWORD'],
    domain: 'sydevelopers.com',
    authentication: :plain,
    enable_starttls_auto: true,
  }

  config.action_mailer.perform_deliveries = true
  config.action_mailer.default_url_options = { host: 'database.sydevelopers.com' }
  config.action_mailer.default_options = { from: "SY Program Database <#{ENV['SMTP_EMAIL']}>" }
  config.action_mailer.raise_delivery_errors = true
end
