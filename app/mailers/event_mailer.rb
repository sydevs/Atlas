class EventMailer < ApplicationMailer

  default template_path: 'mail/events'
  layout 'mail/admin'

  def status
    setup
    return if status.nil?

    puts "[MAIL] Sending status email for #{@event.label} to #{@manager.name}"
    create_session!
    subject = I18n.translate(@status, scope: 'mail.event.status.title')
    parameters = { to: @manager.email, subject: subject }
    if status == :needs_urgent_review
      parameters['Importance'] = 'high'
      parameters['X-Priority'] = '1'
    end

    mail(parameters)
    @event.update_column(:summary_email_sent_at, Time.now) unless params[:test]
  end

  def reminder
    setup

    puts "[MAIL] Sending reminder email for #{@event.label} to #{@manager.name}"
    create_session!
    @registrations = @event.registrations.since(@event.reminder_emails_sent_at || @event.created_at)
    @registrations = @event.registrations.limit(10) if params[:test] && @registrations.empty?
    subject = I18n.translate('mail.event.reminder.subject')
    mail(to: @manager.email, subject: subject)
    @event.update_column(:reminder_emails_sent_at, Time.now) unless params[:test]
  end

  private

    def setup
      @event = params[:event]
      @manager = @event.manager

      if @event.expired?
        @status = :expired
      elsif @event.needs_urgent_review?
        @status = :needs_urgent_review
      elsif @event.needs_review?
        @status = :needs_review
      elsif @event.created_at > 1.week.ago
        @status = :created
      else
        @status = nil
      end
    end

end
