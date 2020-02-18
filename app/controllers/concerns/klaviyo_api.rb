require 'httparty'
require 'pp'

## KLAVIYO
# This concern simplifies requests to Klaviyo

module KlaviyoAPI

  def self.subscribe registration
    puts "Test #{ENV['KLAVIYO_API_KEY']} / #{ENV['KLAVIYO_LIST_ID']}"
    return unless ENV['KLAVIYO_API_KEY'].present?
    raise ArgumentError, "No newsletter ID has been defined." unless ENV['KLAVIYO_LIST_ID'].present?

    name = registration.name.split(' ')

    Klaviyo.request("api/v2/list/#{ENV['KLAVIYO_LIST_ID']}/subscribe", {
      'api_key': ENV['KLAVIYO_API_KEY'],
      'profiles': [{
        'email': registration.email,
        'first_name': name.first,
        'last_name': name.length > 1 ? name.last : '',
        '$consent': 'email',
        'language': I18n.locale,
      }],
    })
  end

  def self.send_registration_event registration
    return unless ENV['KLAVIYO_API_KEY'].present?

    @klaviyo ||= Klaviyo::Client.new(ENV['KLAVIYO_API_KEY'])
    registration = ActiveDecorator::Decorator.instance.decorate(registration)
    event = ActiveDecorator::Decorator.instance.decorate(registration.event)
    venue = ActiveDecorator::Decorator.instance.decorate(event.venue)
    name = registration.name.split(' ')
  
    @klaviyo.track('Registered for Class', {
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
        'address1': venue.street,
        'city': venue.city,
        'region': venue.province_name,
        'country': venue.country_name,
        'postcode': venue.postcode,
        'latitude': venue.latitude,
        'longitude': venue.longitude,
        'timing': event.formatted_start_end_time,
        'weekday': registration.starting_at_weekday,
        'date': registration.starting_at.strftime("%-d %b %Y"),
        'language': event.language_names.first,
        'url': Rails.application.routes.url_helpers.map_root_url(event: event.id, host: 'https://atlas.sydevelopers.com'),
      },
    })

=begin
    Klaviyo.send('api/track', {
      'api_key': ENV['KLAVIYO_API_KEY'],
      'event': 'Registered for Class',
      'customer_properties': {
        '$email': registration.email,
        '$first_name': name.first,
        '$last_name': name.length > 1 ? name.last : '',
        'language': I18n.locale,
      },
      'properties': {
        '$event_id': registration.id,
        'room': event.room,
        'address1': venue.street,
        'city': venue.city,
        'region': venue.province_name,
        'country': venue.country_name,
        'latitude': venue.latitude,
        'longitude': venue.longitude,
        'timing': event.timing_in_words,
        'weekday': registration.starting_at_weekday,
        'date': registration.starting_at.strftime("%-d %b %Y"),
        'language': event.languages.first,
        'url': Rails.application.routes.url_helpers.map_root_url(event: event.id, host: 'https://atlas.sydevelopers.com'),
      },
    })
=end
  end

  private
  
    def self.request path, request_params
      puts "Klaviyo Request - #{path}"
      HTTParty.post("https://a.klaviyo.com/#{path}", {
        body: request_params.to_json,
        headers: {
          'Content-Type': 'application/json'
        },
        log_level: :debug,
      })
    end
  
    def self.send path, send_params
      puts "Klaviyo Send - #{path}"
      HTTParty.get("https://a.klaviyo.com/#{path}", {
        data: Base64.encode64(send_params.to_json),
        headers: {
          'Content-Type': 'application/json'
        },
        log_level: :debug,
      })
    end

end
