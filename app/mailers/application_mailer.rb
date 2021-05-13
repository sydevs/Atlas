class ApplicationMailer < ActionMailer::Base

  helper Mail::ApplicationHelper
  helper LocalizationHelper
  layout 'mailer/public'
  default template_path: 'mailer'
  default from: 'contact@sydevelopers.com'

  def session
    @session ||= begin
      session = Passwordless::Session.new({
        authenticatable: @manager,
        user_agent: 'Command Line',
        remote_addr: 'unknown',
      })

      session.save!
      session
    end
  end

end
