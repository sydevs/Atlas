class RegistrationMailer < ApplicationMailer

  before_action -> {
    @registration = params[:registration] || params[:record]
    @manager = @registration.manager
  }

  def confirmation
    event = @registration.event
    scope = "emails.confirmation.#{event.layer}"
    title = I18n.translate('subject', scope: scope, event_name: event.label)

    text = {
      header: I18n.translate('header', scope: scope, name: @registration.first_name, event_name: event.label)
    }

    %i[subheader invite_a_friend get_directions joining_title joining_content faqs].each do |field|
      text[field] = I18n.translate(field, scope: scope, event_name: event.label)
    end

    text[:faqs] = nil # This temporarily disables all FAQ text.

    conversation = @registration.conversations.create!

    result = BrevoAPI.send_email(:confirmation, {
      subject: title,
      to: [{ name: @registration.name, email: @registration.email }],
      replyTo: { email: conversation.reply_to },
      params: {
        name: @registration.first_name,
        url: event.map_url,
        label: event.label,
        address: event.address,
        room: event.room,
        timing: event.recurrence_in_words(%i[timing]),
        date: @registration.starting_date.to_s(:short),
        weekday: @registration.starting_at_weekday.upcase,
        online: event.online? ? true : nil,
        link: event.online? ? event.online_url : event.decorated_venue&.directions_url,
        directions_url: event.decorated_venue&.directions_url,
        responses: @registration.questions.map do |question, answer|
          {
            question: I18n.translate(question, scope: 'activerecord.attributes.event.registration_questions'),
            answer: answer,
          } if answer.present?
        end.compact,
        text: text,
      },
    })

    @registration.audits.create!({
      category: :notice_sent,
      conversation: @registration.conversations.new,
      person: @registration.user,
      data: {
        sent_to: @registration.user.email,
        subject: title,
        message_id: result&.message_id,
      }
    })

    event.update_column(:status_email_sent_at, Time.now) unless params[:test]
  end

  def question
    return unless @registration.questions['questions'].present?

    helpers = ApplicationController.helpers
    title = I18n.translate('emails.question.title')
    conversation = @registration.conversations.create!

    result = BrevoAPI.send_email(:registrations, {
      subject: title,
      to: [{ name: @registration.manager.name, email: @registration.manager.email }],
      replyTo: { email: conversation.reply_to },
      params: {
        text: {
          title: title,
          prelude: I18n.translate('emails.question.prelude'),
          reply: I18n.translate('emails.question.reply'),
          view_map: I18n.translate('emails.common.view_map'),
          footer: I18n.translate('emails.footer'),
        },
        event: {
          label: @registration.event.label,
          questions: 'questions',
          cms_url: sign_in_link(cms_event_url(@registration.event)),
          map_url: @registration.event.map_url,
        },
        registrations: [{
          summary: I18n.translate('emails.question.summary', name: @registration.name),
          description: I18n.translate('emails.question.description', time: @registration.created_at.to_fs(:short)),
          reply_url: "mailto:#{conversation.reply_to}?subject=Re:%20#{@registration.questions['questions']}",
          answers: { questions: @registration.questions['questions'] },
        }],
      },
    })

    @registration.audits.create!({
      category: :question_asked,
      conversation: conversation,
      person: @registration.user,
      data: {
        sent_to: @registration.manager.email,
        body: @registration.questions['questions'],
        message_id: result&.message_id,
      }
    })
  end

end
