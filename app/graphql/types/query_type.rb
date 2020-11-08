module Types
  class QueryType < Types::BaseObject
    description "The query root of this schema"

    field :geojson, GeojsonType, 'Returns all events in the geojson format', null: false

    field :venues, [VenueType], 'Returns all events', null: false
    field :events, [EventType], null: false do
      description 'Returns all events'
      argument :online, Boolean, required: false
    end

    field :event, EventType, null: true do
      description "Find an event by ID"
      argument :id, ID, required: true
    end

    field :venue, VenueType, null: true do
      description "Find a venue by ID"
      argument :id, ID, required: true
    end

    field :closest_venue, VenueType, null: true do
      description "Find the closest event to some coordinates"
      argument :latitude, Float, required: true
      argument :longitude, Float, required: true
    end


    def geojson
      venues = decorate Venue.publicly_visible

      {
        type: 'FeatureCollection',
        features: venues.map do |venue|
          {
            type: 'Feature',
            id: venue.id,
            geometry: {
              type: 'Point',
              coordinates: [venue.longitude, venue.latitude]
            },
            properties: venue,
          }
        end,
        created_at: DateTime.now.to_s,
      }
    end
  
    def event(id:)
      decorate Event.find(id)
    end
  
    def venue(id:)
      decorate Venue.find(id)
    end

    def events(online: nil)
      scope = Event.publicly_visible

      if online == true
        scope = scope.where(online: true)
      elsif online == false
        scope = scope.where(online: false)
      end

      decorate scope
    end

    def venues
      decorate Venue.publicly_visible
    end

    def closest_venue(latitude:, longitude:)
      decorate Venue.publicly_visible.by_distance(origin: [latitude, longitude]).first
    end

    def decorate object
      if object.is_a? ActiveRecord::Relation
        object.map { |r| r.extend("#{object.model}Decorator".constantize) }
      else
        object.extend("#{object.class}Decorator".constantize)
      end
    end
  end
end
