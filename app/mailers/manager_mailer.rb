
class ManagerMailer < ApplicationMailer
 
  def welcome
    setup
    subject = I18n.translate('mail.welcome.subject', event: @event.label)
    mail(to: @manager.email, subject: subject)
  end

  def registrations
    setup
    @since = params[:since]
    @registrations = params[:registrations] || @event&.registrations
    @registrations = @registrations.where('created_at > ?', @since) if @since
    subject = I18n.translate('mail.registrations.subject', date: @since.to_s(:short))
    mail(to: @manager.email, subject: subject)
  end

  def verification
    setup
    subject = I18n.translate('mail.verification.subject', event: @event.label)
    mail(to: @manager.email, subject: subject)
  end

  def escalation
    setup session: false
    subject = I18n.translate('mail.escalation.subject', event: @event.label)
    mail(to: @manager.email, subject: subject)
  end

  private

    def setup session: true
      @manager = params[:manager]
      @event = params[:event]

      if session
        session = Passwordless::Session.new({
          authenticatable: @manager,
          user_agent: 'Command Line',
          remote_addr: 'unknown',
        })
        session.save!
        @magic_link = send(Passwordless.mounted_as).token_sign_in_url(session.token)
      end
    end
  
end
