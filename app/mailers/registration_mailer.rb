class RegistrationMailer < ApplicationMailer

  default template_path: 'mailer/registrations'
  layout 'mailer/public'

  def confirmation
    @registration = params[:registration]
    @event = @registration.event
    subject = I18n.translate('mail.confirmation.subject', event: @event.label)
    mail(to: @registration.email, subject: subject)
  end

end
