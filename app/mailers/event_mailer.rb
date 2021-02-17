class EventMailer < ApplicationMailer

  default template_path: 'mailer/events'
  layout 'mailer/admin'

  def summary
    setup

    if @event.recently_expired?
      @status = 'expired'
    elsif @event.needs_review?(:urgent)
      @status = 'needs_urgent_review'
    elsif @event.needs_review?
      @status = 'needs_review'
    else
      return
    end

    @registrations = @event.registrations.since(@event.summary_email_sent_at || @event.created_at)
    @registrations = @event.registrations.limit(10) if params[:test] && !@registrations.present?

    return unless @registrations.present?

    @edit_event_link = "#{@magic_link}?destination_path=#{url_for([:edit, :cms, @event])}"
    @view_registrations_link = "#{@magic_link}?destination_path=#{url_for([:cms, @event, :registrations])}"

    subject = I18n.translate('mail.event_summary.subject', event: @event.label, date: Date.today.to_s(:short))
    puts "[MAIL] Sending summary email for #{event.custom_name || event.venue.street} to #{@manager.name}"
    mail(to: @manager.email, subject: subject)
    @event.touch(:summary_email_sent_at) unless params[:test]
  end

  private

    def setup
      @event = params[:event]
      @manager = @event.manager

      session = Passwordless::Session.new({
        authenticatable: @manager,
        user_agent: 'Command Line',
        remote_addr: 'unknown',
      })
      session.save!

      @magic_link = send(Passwordless.mounted_as).token_sign_in_url(session.token)
    end

end
