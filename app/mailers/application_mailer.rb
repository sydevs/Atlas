class ApplicationMailer < ActionMailer::Base

  helper Mail::ApplicationHelper
  default template_path: 'mailer'
  default from: 'contact@sydevelopers.com'

end
