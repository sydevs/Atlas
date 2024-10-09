
## BREVO
# This concern simplifies requests to brevo.com

module BrevoAPI
  include Rails.application.routes.url_helpers

  LISTS = {
    registrations: 13,
    managers: 19,
    test: 15,
  }.freeze

  TEMPLATES = {
    confirmation: 9,
    reminder: 12,
    status: 198,
    registrations: 201,
  }.freeze

  def self.subscribe email, list_id, attributes
    return if Rails.env.development?

    client = SibApiV3Sdk::ContactsApi.new
    list_id = BrevoAPI::LISTS[list_id]

    # Create a contact
    p client.create_contact(
      'email' => email,
      'attributes' => attributes.deep_transform_keys { |key| key.to_s.upcase },
      'listIds' => [list_id.to_i],
      'updateEnabled' => true
    )
  rescue SibApiV3Sdk::ApiError => e
    puts "Exception when calling ContactsApi->create_contact: #{e} #{e.response_body}"
  end

  def self.unsubscribe email, list_id
    return if Rails.env.development?
    
    client = SibApiV3Sdk::ContactsApi.new
    list_id = BrevoAPI::LISTS[list_id]

    # Create a contact
    p client.remove_contact_from_list(list_id, {
      'emails' => [email],
    })
  rescue SibApiV3Sdk::ApiError => e
    puts "Exception when calling ContactsApi->update_contact: #{e} #{e.response_body}"
  end

  def self.update_contact email, attributes
    return if Rails.env.development?
    
    client = SibApiV3Sdk::ContactsApi.new
    attributes.deep_transform_keys! { |key| key.to_s.upcase }

    # Update a contact
    p client.update_contact(email, 'attributes' => attributes)
  rescue SibApiV3Sdk::ApiError => e
    puts "Exception when calling ContactsApi->update_contact: #{e} #{e.response_body}"
  end

  def self.send_email template, config
    puts "[Brevo] Send #{template}"
    if Rails.env.development?
      puts config.to_json
      return
    end
    
    config.reverse_merge!({
      templateId: BrevoAPI::TEMPLATES[template],
      params: {},
      tags: [],
    })

    config[:bcc] = [{ name: "Sahaj Atlas", email: "contact@sydevelopers.com" }] unless %i[confirmation reminder].include?(template)

    config[:tags] << 'atlas'
    config[:tags] << template.to_s

    config[:params][:text] ||= {}
    config[:params][:text].reverse_merge!(I18n.translate('emails.common'))

    client = SibApiV3Sdk::TransactionalEmailsApi.new
    client.send_transac_email(config)
  rescue SibApiV3Sdk::ApiError => e
    puts "Exception when calling TransactionalEmailsApi->send_transac_email: #{e} #{e.response_body}"
  end

  def self.schedule_reminder_email registration
    return if Rails.env.development?
    
    registration = registration.extend(RegistrationDecorator)
    event = registration.event.extend(EventDecorator)
    scope = "emails.reminder.#{event.layer}"

    text = {
      header: I18n.translate('header', scope: scope, name: registration.first_name),
    }

    %i[subheader action].each do |field|
      text[field] = I18n.translate(field, scope: scope, event_name: event.label)
    end

    schedule_at = registration.starting_at - (event.online? ? 1.hour : 1.day)
    schedule_at = 1.minute.from_now if event.online? && schedule_at < Time.now
    # schedule_at = 1.minute.from_now # For development
    return if schedule_at < Time.now

    BrevoAPI.send_email(:reminder, {
      scheduledAt: schedule_at.utc.iso8601,
      subject: I18n.translate('subject', scope: scope, event_name: event.label),
      to: [{ name: registration.name, email: registration.email }],
      params: {
        name: registration.first_name,
        label: event.label,
        address: event.address,
        room: event.room,
        timing: event.recurrence_in_words(%i[timing]),
        date: registration.starting_date.to_s(:short),
        weekday: registration.starting_at_weekday.upcase,
        link: event.online? ? event.online_url : event.decorated_venue&.directions_url,
        text: text,
      },
    })
  end

end
