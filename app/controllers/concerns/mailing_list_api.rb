
## MAILING LISTS
# This concern simplifies code for subscribing users to various mailing list services

module MailingListAPI
  include Rails.application.routes.url_helpers

  def self.subscribe registration
    country = registration.event.area&.country
    return if registration.mailing_list_subscribed_at.present?
    return unless country&.mailing_list_service.present?

    self.send(:"subscribe_to_#{country.mailing_list_service}",
      api_key: country.mailing_list_api_key,
      list_id: country.mailing_list_list_id,
      attributes: {
        email: email,
        firstname: first_name,
        lastname: last_name,
        timezone: time_zone,
        city: event.area&.name,
        state_region: event.area&.region&.name,
        country: event.area&.country&.name,
        how_they_joined: "Sahaj Atlas Registration",
        language: LocalizationHelper.language_name(event.language_code),
        latitude: (event.venue&.latitude || event.area&.latitude),
        longitude: (event.venue&.longitude || event.area&.longitude),
      },
    )

    registration.touch(:mailing_list_subscribed_at)
  end

  def self.subscribe_to_brevo api_key, list_id, attributes
    return if Rails.env.development?

    api_client = Brevo::ApiClient.new(Configuration.new(api_key: api_key))
    client = Brevo::ContactsApi.new(api_client)

    # Create a contact
    p client.create_contact(
      'email' => attributes[:email],
      'attributes' => attributes.deep_transform_keys { |key| key.to_s.upcase },
      'listIds' => [list_id.to_s],
      'updateEnabled' => true
    )
  rescue Brevo::ApiError => e
    puts "Exception when calling Brevo::ContactsApi->create_contact: #{e} #{e.response_body}"
  end

end
