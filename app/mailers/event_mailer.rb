class EventMailer < ApplicationMailer

  default template_path: 'mailer/events'
  layout 'mailer/admin'

  def summary
    setup

    @status = nil
    if @event.expired?
      @status = 'expired'
    elsif @event.needs_review?(:urgent)
      @status = 'needs_urgent_review'
    else
      @status = 'needs_review'
    end

    @registrations = @event.registrations.since(@event.summary_email_sent_at || @event.created_at)
    @registrations = @event.registrations.limit(10) if params[:test]
    @edit_event_link = "#{@magic_link}?destination_path=#{url_for([:edit, :cms, @event])}"
    @view_registrations_link = "#{@magic_link}?destination_path=#{url_for([:cms, @event, :registrations])}"

    subject = I18n.translate('mail.event_summary.subject', event: @event.label, date: Date.today.to_s(:short))
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
