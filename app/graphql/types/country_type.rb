module Types
  class CountryType < Types::BaseObject
    field :id, ID, null: false
    field :path, String, null: false, method: :map_path
    field :url, String, null: false, method: :map_url

    field :label, String, null: false
    field :bounds, [Float], null: false

    field :events, [Types::EventType], null: false
    field :event_ids, [ID], null: false
    field :event_count, Int, null: false
    field :online_event_ids, [ID], null: false
    field :offline_event_ids, [ID], null: false

    field :venues, [Types::VenueType], null: false
    field :areas, [Types::AreaType], null: false
    field :regions, [Types::RegionType], null: false

    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: false

    def events
      object.events.publicly_visible.map { |event| event.extend(EventDecorator) }
    end

    def event_ids
      object.events.publicly_visible.pluck(:id)
    end

    def event_count
      object.events.count
    end

    def online_event_ids
      object.events.online.publicly_visible.pluck(:id)
    end

    def offline_event_ids
      object.events.offline.publicly_visible.pluck(:id)
    end

    def venues
      object.venues.publicly_visible.map { |venue| venue.extend(VenueDecorator) }
    end

    def areas
      object.areas.publicly_visible.map { |area| area.extend(AreaDecorator) }
    end

    def regions
      object.regions.publicly_visible.map { |region| region.extend(RegionDecorator) }
    end
  end
end
