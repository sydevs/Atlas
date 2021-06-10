class EventMailer < ApplicationMailer

  default template_path: 'mail/events'
  layout 'mail/admin'

  def status
    setup
    if @status.present? && @status != :verified
      puts "[MAIL] Sending status email (#{@event.status}) for #{@event.label} to #{@manager.name}"
    else
      puts "[MAIL] Skip sending status for #{@event.label}"
      return
    end

    create_session!
    subject = I18n.translate(@status, scope: 'mail.event.status.title', event: @event.label)
    parameters = { to: @manager.email, subject: subject }
    if @status == :needs_urgent_review
      parameters['Importance'] = 'high'
      parameters['X-Priority'] = '1'
    end

    mail(parameters)

    if @status == :needs_urgent_review
      @event.venue.parent.managers.each do |manager|
        puts "[MAIL] Sending status email to city manager: #{manager.name}"
        @manager = manager
        mail(parameters.merge({ to: manager.email }))
      end
    end

    @event.update_column(:status_email_sent_at, Time.now) unless params[:test]
  end

  def reminder
    setup
    if (params && params[:test]) || (@event.next_occurrence_at && @event.next_occurrence_at <= 1.day.from_now)
      puts "[MAIL] Sending reminder email for #{@event.label} to #{@manager.name}"
    else
      puts "[MAIL] Skip sending status for #{@event.label}"
      return
    end

    create_session!
    @registrations = @event.registrations.since(@event.reminder_email_sent_at || @event.created_at)
    @registrations = @event.registrations.limit(10) if params[:test] && @registrations.empty?
    subject = I18n.translate('mail.event.reminder.subject', event: @event.label)
    mail(to: @manager.email, subject: subject)
    @event.update_column(:reminder_email_sent_at, Time.now) unless params[:test]
  end

  private

    def setup
      @event = params[:event] || params[:record]
      @manager = params[:manager] || @event.manager
      @status = @event.status.to_sym
      @status = :created if @status == :verified && @event.created_at > 1.week.ago
    end

end
