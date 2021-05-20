class ManagerMailer < ApplicationMailer

  default template_path: 'mail/managers'
  layout 'mail/admin'

  def welcome
    setup
    
    subject = I18n.translate('mail.manager.welcome.title', context: @context&.label)
    puts "[MAIL] Sending welcome email to #{@manager.name} for #{@context}"
    mail(to: @manager.email, subject: subject)
  end

  private

    def setup
      @manager = params[:manager] || params[:record]
      @context = params[:context] || @manager.parent
      create_session!
    end

end
