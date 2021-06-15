class ManagerMailer < ApplicationMailer

  default template_path: 'mail/managers'
  layout 'mail/admin'

  def welcome
    setup
    
    subject = I18n.translate(@manager.type, scope: 'mail.manager.welcome.subject')
    puts "[MAIL] Sending welcome email to #{@manager.name} for #{@context}"
    mail(to: @manager.email, subject: subject)
  end

  def new_managed_record
    managed_record = params[:managed_record]
    @manager = managed_record&.manager || params[:manager]
    @record = managed_record&.record || params[:record]
    create_session!

    subject = I18n.translate('mail.manager.new_managed_record.title', context: @context&.label)
    puts "[MAIL] Sending new managed record email to #{@manager.name} for #{@context}"
    mail(to: @manager.email, subject: subject)
  end

  private

    def setup
      @manager = params[:manager] || params[:record]
      @context = params[:context] || @manager.parent
      create_session!
    end

end
