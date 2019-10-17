
class SummaryMailer < ApplicationMailer
  default template_path: 'mailer/summaries'
  layout 'mailer/cms'

  def regional
    setup
    @region = params[:region]
    @reviewable_events = @region.events.offset(5).first(5) # .needs_urgent_review
    @expired_events = @region.events.first(5) # .recently_expired
    subject = I18n.translate('mail.regional_summary.subject', region: @region.label)
    mail(to: @manager.email, subject: subject)
  end

  def global
    setup
    @recent_registrations = Registration.since(1.week.ago)
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
