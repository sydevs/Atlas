class ManagerMailer < ApplicationMailer

  default template_path: 'mail/managers'
  layout 'mail/admin'

  def welcome
    setup
    subject = I18n.translate(@manager.type, scope: 'mail.manager.welcome.subject')
    puts "[MAIL] Sending welcome email to #{@manager.name} for #{@context}"
    mail(to: @manager.email, subject: subject)
  end

  def verify
    setup
    subject = I18n.translate('mail.manager.verify.subject')
    puts "[MAIL] Sending verification email to #{@manager.name} for #{@context}"
    mail(to: @manager.email, subject: subject)
  end

  private

    def setup
      @manager = params[:manager] || params[:record]
      @context = params[:context] || @manager.parent
      create_session!
    end

end
