module Types
  class QueryType < Types::BaseObject
    description 'The query root of this schema'

    # SPECIAL QUERIES

    field :geojson, GeojsonType, null: false do
      description 'Returns all events in the geojson format'
      argument :online, Boolean, required: false
      argument :country, String, required: false
      argument :area, String, required: false
      argument :locale, String, required: false
    end

    field :closest_venue, VenueType, null: true do
      description 'Find the closest event to some coordinates'
      argument :latitude, Float, required: true
      argument :longitude, Float, required: true
      argument :locale, String, required: false
    end

    # LIST QUERIES

    field :venues, [VenueType], null: false do
      description 'Returns all venues'
      argument :locale, String, required: false
    end

    field :events, [EventType], null: false do
      description 'Returns all events'
      argument :ids, [ID], required: false
      argument :online, Boolean, required: false
      argument :country, String, required: false
      argument :recurrence, String, required: false
      argument :language_code, String, required: false
      argument :locale, String, required: false
    end

    # INDIVIDUAL QUERIES

    field :country, CountryType, null: true do
      description 'Find a country by code'
      argument :code, String, required: true
      argument :locale, String, required: false
    end

    field :area, LocalAreaType, null: true do
      description 'Find a local area by id'
      argument :id, ID, required: true
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


    # Methods

    def geojson(online: nil, country: nil, area: nil, locale: 'en')
      I18n.locale = locale.to_sym

      if area
        scope = LocalArea.where(id: area)
        scope = scope.venues unless online
      else
        scope = online ? LocalArea : Venue
        scope = scope.where(country_code: country) if country
      end

      locations = decorate scope.publicly_visible

      {
        type: 'FeatureCollection',
        features: locations.map do |location|
          events = location.events.publicly_visible
          next if events.empty?

          {
            type: "Feature #{events.length}",
            id: location.id,
            geometry: {
              type: 'Point',
              coordinates: [location.longitude, location.latitude]
            },
            properties: location,
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
  
    def area(id:, locale: 'en')
      I18n.locale = locale.to_sym
      decorate LocalArea.find(id)
    end

    def country(code:, locale: 'en')
      I18n.locale = locale.to_sym
      decorate Country.find_by_country_code(code)
    end

    def events(ids: [], online: nil, country: nil, recurrence: nil, language_code: nil, locale: 'en')
      I18n.locale = locale.to_sym
      scope = online ? OnlineEvent : OfflineEvent
      scope = scope.publicly_visible
      scope = scope.joins(:location).where(locations: { country_code: country }) if country.present?
      scope = scope.where(recurrence: recurrence) if Event.recurrences.key?(recurrence)
      scope = scope.where(language_code: language_code) if language_code.present?
      scope = scope.where(id: ids) if ids.present?
      
      decorate scope
    end

    def venues(locale: 'en')
      I18n.locale = locale.to_sym
      decorate Venue.publicly_visible
    end

    def closest_venue(latitude:, longitude:, locale: 'en')
      I18n.locale = locale.to_sym
      decorate Venue.publicly_visible.by_distance(origin: [latitude, longitude]).first
    end

    def decorate object
      return nil if object.nil?

      klass = object.is_a?(ActiveRecord::Relation) ? object.model : object.class
      klass = Event if klass.base_class == Event

      if object.is_a?(ActiveRecord::Relation)
        object.map { |r| r.extend("#{klass}Decorator".constantize) }
      else
        object.extend("#{klass}Decorator".constantize)
      end
    end
  end
end
