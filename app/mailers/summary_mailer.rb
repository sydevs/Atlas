
class SummaryMailer < ApplicationMailer
  default template_path: 'mailer/summaries'
  layout 'mailer/manager'

  def regional
    setup
    @region = params[:region]
    @new_events = @region.events.reorder(:created_at).where('events.created_at > ?', 1.week.ago)
    @reviewable_events = @region.events.needs_urgent_review
    @expired_events = @region.events.recently_expired
    subject = I18n.translate('mail.regional_summary.subject', region: @region.label)
    mail(to: @manager.email, subject: subject)
  end

  def global
    setup
    @recent_registrations = Registration.since(1.week.ago)
    @new_events = Event.reorder(:created_at).where('created_at > ?', 1.week.ago)
    @reviewable_events = Event.needs_urgent_review
    @expired_events = Event.recently_expired
    subject = I18n.translate('mail.global_summary.subject')
    mail(to: @manager.email, subject: subject)
  end

  private

    def setup session: true
      @manager = params[:manager]

      if session || (session == :auto && @event.managers.include?(@manager))
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
