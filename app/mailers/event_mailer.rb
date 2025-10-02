class EventMailer < ApplicationMailer

  before_action -> {
    @event = params[:event] || params[:record]
    @manager = params[:manager] || @event.manager
  }

  def status
    if @event.status.present? && @event.status.to_sym != :verified
      puts "[MAIL] Sending status message (#{@event.status}) for #{@event.label} to #{@manager.name}"
    else
      puts "[MAIL] Skip sending status for #{@event.label} (#{@event.status})"
      return
    end

    helpers = ApplicationController.helpers

    is_checkup = @manager != @event.manager
    scope = (is_checkup ? "emails.status.checkup" : "emails.status.#{@event.status}")
    expiration_period = helpers.time_ago_in_words(@event.should_expire_at)
    title = I18n.translate('title', scope: scope, period: expiration_period)

    result = BrevoAPI.send_email(:status, {
      subject: title,
      to: [{ name: @manager.name, email: @manager.email }],
      params: {
        text: I18n.translate(scope).deep_dup.merge!({
          title: title,
          flash: I18n.translate('flash', scope: scope, period: expiration_period).upcase,
          footer: I18n.translate('emails.footer'),
          view_map: I18n.translate('emails.common.view_map'),
          recommendation_title: I18n.translate('emails.recommendations.title'),
          recommendation_prelude: I18n.translate('emails.recommendations.prelude'),
          # These translations are references to other translations, so we need to call them directly
          event: I18n.translate('emails.status.event').map do |key, ref|
            [key, I18n.translate(ref)]
          end.to_h
        }),
        event: {
          status: @event.status,
          label: @event.label,
          map_url: @event.map_url,
          location: @event.address,
          timing: @event.recurrence_in_words(short: true),
          contact: @event.contact_text,
          category: @event.category_label,
          updated_at: @event.updated_at.to_s(:short),
        },
        recommendations: @event.recommendations.map do |key, link|
          I18n.translate(key, scope: 'emails.recommendations').merge({
            link: sign_in_link(link),
            image: helpers.image_url("email/recommendations/#{key}.png", host: 'https://atlas.sydevelopers.com'),
          })
        end,
        links: {
          positive: sign_in_link(change_cms_event_url(@event, effect: :verify)),
          negative: sign_in_link(edit_cms_event_url(@event)),
          tertiary: sign_in_link(is_checkup ? "mailto:#{@event.manager.email}" : change_cms_event_url(@event, effect: :finish)),
        }
      },
    })

    @event.audits.create!({
      category: :notice_sent,
      conversation: @event.conversations.new,
      # replies_to: @event.audits.status_change.last, # Doesn't seem to reliably fetch the correct audit, because of async
      person: @manager,
      data: {
        sent_to: @manager.email,
        subject: title,
        status: @event.status,
        updated_at: @event.updated_at.to_fs(:long),
        message_id: result&.message_id,
      }
    })

    @event.update_column(:status_email_sent_at, Time.now)
  end

  def registrations
    if params[:registration].present?
      registrations = [params[:registration]]
      puts "[MAIL] Sending single registration email for #{@event.label} to #{@manager.name}"
    else
      registrations = @event.registrations.order_with_comments_first.since(@event.registrations_email_sent_at || @event.created_at)
      puts "[MAIL] Sending registrations email for #{@event.label} to #{@manager.name}"
    end

    return unless registrations.present?

    helpers = ApplicationController.helpers
    title = I18n.translate('emails.registrations.title', count: registrations.count, event: @event.label)
    conversation = @event.conversations.create!

    result = BrevoAPI.send_email(:registrations, {
      subject: title,
      to: [{ name: @manager.name, email: @manager.email }],
      params: {
        text: {
          title: title,
          prelude: I18n.translate('emails.registrations.prelude', event: @event.label, count: registrations.count),
          reply: I18n.translate('emails.registrations.registration.reply'),
          view_map: I18n.translate('emails.common.view_map'),
          answers: I18n.translate('activerecord.attributes.event.registration_questions'),
          footer: I18n.translate('emails.footer'),
        },
        event: {
          questions: @event.registration_question.to_a.excluding('questions').join(','),
          map_url: @event.map_url,
        },
        registrations: registrations.map do |r|
          {
            summary: I18n.translate('emails.registrations.registration.summary', name: r.name, time: helpers.time_ago_in_words(r.created_at)),
            description: I18n.translate('emails.registrations.registration.description', date: r.starting_at.to_date.strftime('%a, %B %-d')),
            reply_url: r.questions['questions'].present? ? "mailto:#{conversation.reply_to}?subject=Re: #{r.questions['questions']}" : nil,
            answers: r.questions,
          }
        end,
      },
    })

    @event.audits.create!({
      category: :notice_sent,
      conversation: conversation,
      person: @manager,
      data: {
        sent_to: @manager.email,
        subject: title,
        message_id: result&.message_id,
      }
    })

    @event.update_column(:registrations_email_sent_at, Time.now)
  end

end
