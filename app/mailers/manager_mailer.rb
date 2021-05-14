class ManagerMailer < ApplicationMailer

  default template_path: 'mail/managers'
  layout 'mail/admin'

  def welcome
    setup
    
    subject = I18n.translate('mail.manager.welcome.title', context: @context&.label)
    puts "[MAIL] Sending welcome email to #{@manager.name} for #{@context}"
    mail(to: @manager.email, subject: subject)
  end

  def summary
    setup

    @new_events = @manager.accessible_events.reorder(:created_at).where('events.created_at > ?', Expirable.date_for(:interval))
    @reviewable_events = @manager.accessible_events.needs_urgent_review
    @expired_events = @manager.accessible_events.recently_expired

    if params[:test]
      @new_events = Event.reorder('RANDOM()').limit(7)
      @reviewable_events = Event.reorder('RANDOM()').limit(3)
      @expired_events = Event.reorder('RANDOM()').limit(11)
    end

    puts "[MAIL] Check email for #{@manager}: new events? #{@new_events.present?}, review? #{@reviewable_events.present?}, expiration? #{@expired_events.present?}"
    return unless @new_events.present? || @reviewable_events.present? || @expired_events.present?
    puts "[MAIL] Sending email"

    @context = @manager.parent
    @limit = 5

    @magic_link = send(Passwordless.mounted_as).token_sign_in_url(session.token)
    @dashboard_link = "#{@magic_link}?destination_path=#{cms_review_url}"
    @template_link = "#{@magic_link}?destination_path="

    subject = I18n.translate('mail.manager_summary.subject', context: @context&.label || I18n.translate('mail.common.sahaj_atlas'), date: Date.today.to_s(:short))
    puts "[MAIL] Sending summary email to #{@manager.name}"
    mail(to: @manager.email, subject: subject)
    @manager.update_column(:summary_email_sent_at, Time.now) unless params[:test]
  end

  private

    def setup
      @manager = params[:manager]
      @context = params[:context] || @manager.parent
      create_session!
    end

end
