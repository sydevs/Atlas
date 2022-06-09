module Types
  class QueryType < Types::BaseObject
    description 'The query root of this schema'

    field :geojson, GeojsonType, null: false do
      description 'Returns all events in the geojson format'
      argument :country, String, required: false
      argument :locale, String, required: false
    end

    field :venues, [VenueType], null: false do
      description 'Returns all venues'
      argument :locale, String, required: false
    end

    field :events, [EventType], null: false do
      description 'Returns all events'
      argument :online, Boolean, required: false
      argument :country, String, required: false
      argument :recurrence, String, required: false
      argument :language_code, String, required: false
      argument :locale, String, required: false
    end

    field :country, CountryType, null: true do
      description 'Find a country by code'
      argument :code, String, required: true
      argument :locale, String, required: false
    end

    field :venue, VenueType, null: true do
      description 'Find a venue by ID'
      argument :id, ID, required: true
      argument :locale, String, required: false
    end

    field :event, EventType, null: true do
      description 'Find an event by ID'
      argument :id, ID, required: true
      argument :locale, String, required: false
    end

    field :closest_venue, VenueType, null: true do
      description 'Find the closest event to some coordinates'
      argument :latitude, Float, required: true
      argument :longitude, Float, required: true
      argument :locale, String, required: false
    end


    def geojson(country: nil, locale: 'en')
      I18n.locale = locale.to_sym
      scope = Venue
      scope = scope.where(country_code: country) if country
      venues = decorate scope.publicly_visible

      {
        type: 'FeatureCollection',
        features: venues.map do |venue|
          events = venue.events.publicly_visible
          next if events.empty?

          {
            type: "Feature #{events.length}",
            id: venue.id,
            geometry: {
              type: 'Point',
              coordinates: [venue.longitude, venue.latitude]
            },
            properties: venue,
          }
        end.compact,
        created_at: DateTime.now.to_s,
      }
    end
  
    def event(id:, locale: 'en')
      I18n.locale = locale.to_sym
      decorate Event.find(id)
    end
  
    def venue(id:, locale: 'en')
      I18n.locale = locale.to_sym
      decorate Venue.find(id)
    end
  
    def country(code:, locale: 'en')
      I18n.locale = locale.to_sym
      decorate Country.find_by_country_code(code)
    end

    def events(online: nil, country: nil, recurrence: nil, language_code: nil, locale: 'en')
      I18n.locale = locale.to_sym
      scope = Event.publicly_visible
      scope = scope.where(online: online) unless online.nil?
      scope = scope.joins(:venue).where(venues: { country_code: country }) unless country.nil?
      scope = scope.where(recurrence: recurrence) if Event.recurrences.key?(recurrence)
      scope = scope.where(language_code: language_code) unless language_code.nil?
      
      decorate scope
    end

    def venues(locale: 'en')
      I18n.locale = locale.to_sym
      decorate Venue.publicly_visible
    end

    def closest_venue(latitude:, longitude:, locale: 'en')
      I18n.locale = locale.to_sym
      venues = Venue.publicly_visible.by_distance(origin: [latitude, longitude]).limit(5)

      venues.each do |venue|
        return decorate(venue) unless venue.publicly_visible_events.empty?
      end

      nil
    end

    def decorate object
      return nil if object.nil?

      if object.is_a? ActiveRecord::Relation
        object.map { |r| r.extend("#{object.model}Decorator".constantize) }
      else
        object.extend("#{object.class}Decorator".constantize)
      end
    end
  end
end
