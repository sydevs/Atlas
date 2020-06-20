class ApplicationMailer < ActionMailer::Base

  helper Mail::ApplicationHelper
  helper LocalizationHelper
  layout 'mailer/public'
  default template_path: 'mailer'
  default from: 'contact@sydevelopers.com'

end
