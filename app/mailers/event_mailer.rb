class EventMailer < ApplicationMailer

  default template_path: 'mail/events'
  layout 'mail/admin'

  def status
    setup

    if @status.present? && @status != :verified
      puts "[MAIL] Sending status message (#{@event.status}) for #{@event.label} to #{@manager.name}"
    else
      puts "[MAIL] Skip sending status for #{@event.label} (#{@event.status})"
      return
    end

    create_session!
    subject = I18n.translate(@status, scope: 'mail.event.status.title', event: @event.label)

    if false && @manager.contact_by_email?
      parameters = { to: @manager.email, subject: subject }
      if @status == :needs_urgent_review
        parameters['Importance'] = 'high'
        parameters['X-Priority'] = '1'
      end

      mail(parameters)
    else
      MessageBirdAPI.send(:support, @manager, [
        { default: 'Roberto Test' },
        { default: '123' },
        { default: 'new coffee machine' },
        { default: 'MessageBird, Trompenburgstraat 2C, 1079TX Amsterdam' }
      ])
    end

    if @status == :needs_urgent_review
      @event.parent_managers.each do |manager|
        puts "[MAIL] Sending status email to city manager: #{manager.name}"
        @manager = manager
        mail(parameters.merge({ to: manager.email }))
      end
    end

    @event.update_column(:status_email_sent_at, Time.now) unless params[:test]
  end

  def registrations
    setup
    return unless @manager.notifications.event_registrations?

    if (params && params[:test]) || (@event.next_occurrence_at && @event.next_occurrence_at <= 1.day.from_now)
      puts "[MAIL] Sending registrations email for #{@event.label} to #{@manager.name}"
    else
      puts "[MAIL] Skip sending reminder for #{@event.label}"
      return
    end

    @registrations = @event.registrations.order_comments_first.since(@event.registrations_email_sent_at || @event.created_at)
    @registrations = @event.registrations.order_comments_first.limit(10) if params[:test] && @registrations.empty?
    return if @registrations.empty?

    create_session!
    subject = I18n.translate('mail.event.registrations.subject', event: @event.label)
    mail(to: @manager.email, subject: subject)
    @event.update_column(:registrations_email_sent_at, Time.now) unless params[:test]
  end

  private

    def setup
      @event = params[:event] || params[:record]
      @manager = params[:manager] || @event.manager
      @status = @event.status.to_sym
      @status = :created if @status == :verified && @event.created_at > 1.week.ago
      create_session!
    end

end
