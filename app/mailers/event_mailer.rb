class EventMailer < ApplicationMailer

  default template_path: 'mail/events'
  layout 'mail/admin'

  def status
    event = params[:event] || params[:record]
    manager = params[:manager] || event.manager
    @manager = manager

    if event.status.present? && event.status.to_sym != :verified
      puts "[MAIL] Sending status message (#{event.status}) for #{event.label} to #{manager.name}"
    else
      puts "[MAIL] Skip sending status for #{event.label} (#{event.status})"
      return
    end

    helpers = ApplicationController.helpers

    is_checkup = manager != event.manager
    scope = (is_checkup ? "emails.status.checkup" : "emails.status.#{event.status}")
    expiration_period = helpers.time_ago_in_words(event.should_expire_at)
    title = I18n.translate('title', scope: scope, period: expiration_period)

    print scope
    BrevoAPI.send_email(:status, {
      subject: title,
      to: [{ name: manager.name, email: manager.email }],
      params: {
        text: I18n.translate(scope).deep_dup.merge!({
          title: title,
          flash: I18n.translate('flash', scope: scope, period: expiration_period).upcase,
          footer: I18n.translate('emails.footer'),
          recommendation_title: I18n.translate('emails.recommendations.title'),
          recommendation_prelude: I18n.translate('emails.recommendations.prelude'),
          # These translations are references to other translations, so we need to call them directly
          event: I18n.translate('emails.status.event').map do |key, ref|
            [key, I18n.translate(ref)]
          end.to_h
        }),
        event: {
          status: event.status,
          label: event.label,
          map_url: event.map_url,
          location: event.address,
          timing: event.recurrence_in_words(short: true),
          contact: event.contact_text,
          category: event.category_label,
          updated_at: event.updated_at.to_s(:short),
        },
        recommendations: event.recommendations.map do |key, link|
          I18n.translate(key, scope: 'emails.recommendations').merge({
            link: sign_in_link(link),
            image: helpers.image_url("email/recommendations/#{key}.png", host: 'https://atlas.sydevelopers.com'),
          })
        end,
        links: {
          positive: sign_in_link(change_cms_event_url(event, effect: :verify)),
          negative: sign_in_link(edit_cms_event_url(event)),
          tertiary: sign_in_link(is_checkup ? "mailto:#{event.manager.email}" : change_cms_event_url(event, effect: :finish)),
        }
      },
    })

    event.update_column(:status_email_sent_at, Time.now) unless params[:test]
  end

  def checkup
    
  end

  def registrations
    setup
    return unless @manager.notifications.event_registrations?

    if (params && params[:test]) || (@event.next_recurrence_at && @event.next_recurrence_at <= 1.day.from_now)
      puts "[MAIL] Sending registrations email for #{@event.label} to #{@manager.name}"
    else
      puts "[MAIL] Skip sending reminder for #{@event.label}"
      return
    end

    @registrations = @event.registrations.order_with_comments_first.since(@event.registrations_email_sent_at || @event.created_at)
    @registrations = @event.registrations.order_with_comments_first.limit(10) if params[:test] && @registrations.empty?
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
