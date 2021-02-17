class ManagerMailer < ApplicationMailer

  default template_path: 'mailer/managers'
  layout 'mailer/admin'

  def welcome
    setup
    
    @context = params[:context]
    @action_link = "#{@magic_link}?destination_path=#{@context.is_a?(Event) ? url_for([:edit, :cms, @context]) : cms_root_url}"
    @type = @context&.model_name&.i18n_key || 'worldwide'
    subject = I18n.translate('mail.welcome.subject', context: @context&.label)
    mail(to: @manager.email, subject: subject)
  end

  def summary
    setup

    @context = @manager.parent
    @new_events = @manager.accessible_events.reorder(:created_at).where('events.created_at > ?', Expirable.date_for(:interval))
    @reviewable_events = @manager.accessible_events.needs_urgent_review
    @expired_events = @manager.accessible_events.recently_expired

    if params[:test]
      @new_events = Event.reorder('RANDOM()').limit(7)
      @reviewable_events = Event.reorder('RANDOM()').limit(3)
      @expired_events = Event.reorder('RANDOM()').limit(11)
    end

    return unless @new_events.present? || @reviewable_events.present? || @expired_events.present?

    @limit = 5

    @dashboard_link = "#{@magic_link}?destination_path=#{cms_review_url}"
    @template_link = "#{@magic_link}?destination_path="

    subject = I18n.translate('mail.manager_summary.subject', context: @context&.label || I18n.translate('mail.common.sahaj_atlas'), date: Date.today.to_s(:short))
    mail(to: @manager.email, subject: subject)
    @manager.touch(:summary_email_sent_at) unless params[:test]
  end

  private

    def setup
      @manager = params[:manager]

      session = Passwordless::Session.new({
        authenticatable: @manager,
        user_agent: 'Command Line',
        remote_addr: 'unknown',
      })
      session.save!
      @magic_link = send(Passwordless.mounted_as).token_sign_in_url(session.token)
    end

end
