require 'klaviyo'
require 'httparty'
require 'pp'

## KLAVIYO
# This concern simplifies requests to Klaviyo

Klaviyo.public_api_key = ENV['KLAVIYO_PUBLIC_API_KEY']
Klaviyo.private_api_key = ENV['KLAVIYO_PRIVATE_API_KEY']

module KlaviyoAPI

  def self.subscribe registration
    return unless ENV['KLAVIYO_PUBLIC_API_KEY'].present? && ENV['KLAVIYO_PRIVATE_API_KEY'].present?

    name = registration.name.split(' ')

    Klaviyo::Lists.add_subscribers_to_list(
      ENV.fetch('KLAVIYO_LIST_ID'),
      profiles: [{
        'email': registration.email,
        'first_name': name.first,
        'last_name': name.length > 1 ? name.last : '',
        '$consent': 'email',
        'language': I18n.locale,
      }]
    )
  end

  def self.send_registration_event registration
    return unless ENV['KLAVIYO_PUBLIC_API_KEY'].present? && ENV['KLAVIYO_PRIVATE_API_KEY'].present?

    registration = ActiveDecorator::Decorator.instance.decorate(registration)
    event = ActiveDecorator::Decorator.instance.decorate(registration.event)
    location = ActiveDecorator::Decorator.instance.decorate(event.location)
    area = ActiveDecorator::Decorator.instance.decorate(event.area)
    name = registration.name.split(' ')
  
    Klaviyo::Public.track('Registered for Class', {
      email: registration.email,
      customer_properties: {
        'first_name': name.first,
        'last_name': name.length > 1 ? name.last : '',
        'language': I18n.locale,
      },
      properties: {
        '$event_id': registration.id,
        'label': event.label,
        'description': event.description,
        'room': event.room,
        'address1': location.address,
        # 'address1': venue.street,
        # 'city': venue.city,
        'region': area.region.name,
        'country': area.country.name,
        # 'postcode': venue.post_code,
        'latitude': location.latitude,
        'longitude': location.longitude,
        'timing': event.formatted_start_end_time,
        'weekday': registration.starting_at_weekday,
        'date': registration.starting_at.strftime("%-d %b %Y"),
        'language': event.language_name,
        'directions_url': location.directions_url,
        'url': event.map_url,
      },
    })
  end

end
