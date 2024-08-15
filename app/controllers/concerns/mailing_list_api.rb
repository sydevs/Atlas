
## MAILING LISTS
# This concern simplifies code for subscribing users to various mailing list services

module MailingListAPI
  include Rails.application.routes.url_helpers

  def self.subscribe! registration
    return unless registration.can_subscribe_to_mailing_list?

    event = registration.event
    success = self.send(:"subscribe_to_#{registration.country.mailing_list_service}",
      registration.country.mailing_list_api_key,
      registration.country.mailing_list_list_id,
      {
        email: registration.user.email,
        firstname: registration.user.first_name,
        lastname: registration.user.last_name,
        timezone: registration.time_zone,
        city: event.area.name,
        state_region: event.area.region&.name,
        country: event.area.country.name,
        how_they_joined: "Sahaj Atlas Registration",
        language: LocalizationHelper.language_name(event.language_code),
        latitude: (event.venue&.latitude || event.area&.latitude),
        longitude: (event.venue&.longitude || event.area&.longitude),
      },
    )

    registration.touch(:mailing_list_subscribed_at) if success
  end

  def self.subscribe_to_brevo api_key, list_id, attributes
    return if Rails.env.development?

    config = Brevo::Configuration.new
    config.api_key['api-key'] = api_key
    api_client = Brevo::ApiClient.new(config)
    client = Brevo::ContactsApi.new(api_client)

    # Create a contact
    p client.create_contact(
      'email' => attributes[:email],
      'attributes' => attributes.deep_transform_keys { |key| key.to_s.upcase },
      'listIds' => [list_id.to_i],
      'updateEnabled' => false
    )

    return true
  rescue Brevo::ApiError => e
    puts "Exception when calling Brevo::ContactsApi->create_contact: #{e} #{e.response_body}"
  end

end
