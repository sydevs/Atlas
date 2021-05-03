Rails.application.configure do
  ActionMailer::Base.delivery_method = :smtp
  ActionMailer::Base.smtp_settings = {
    address: 'smtp.gmail.com',
    port: 465,
    user_name: ENV['SMTP_EMAIL'],
    password: ENV['SMTP_PASSWORD'],
    domain: 'sydevelopers.com',
    authentication: :plain,
    enable_starttls_auto: true,
  }

  config.action_mailer.perform_deliveries = true
  config.action_mailer.default_options = { from: "Sahaj Atlas <#{ENV['SMTP_EMAIL']}>" }
  config.action_mailer.raise_delivery_errors = true
end
