class ManagerMailer < ApplicationMailer

  default template_path: 'mailer/managers'
  layout 'mailer/manager'

  def welcome
    setup
    subject = I18n.translate('mail.welcome.subject', event: @event.label)
    mail(to: @manager.email, subject: subject)
  end

  def registrations
    setup
    @registrations = @event.registrations.since(@event.registrations_sent_at || @event.created_at)
    subject = I18n.translate('mail.registrations.subject', date: @event.registrations_sent_at)
    mail(to: @manager.email, subject: subject)
    @event.touch(:registrations_sent_at) unless params[:test]
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

  def expired
    setup session: :auto
    subject = I18n.translate('mail.expired.subject', event: @event.label)
    mail(to: @manager.email, subject: subject)
  end

  private

    def setup session: true
      @manager = params[:manager]
      @event = params[:event]
      return unless session || (session == :auto && @event.managers.include?(@manager))

      session = Passwordless::Session.new({
        authenticatable: @manager,
        user_agent: 'Command Line',
        remote_addr: 'unknown',
      })
      session.save!
      @magic_link = send(Passwordless.mounted_as).token_sign_in_url(session.token)
    end

end
