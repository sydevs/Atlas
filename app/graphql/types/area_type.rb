module Types
  class AreaType < LocationType
    field :path, String, null: false, method: :map_path
    field :url, String, null: false, method: :map_url
    
    field :radius, Float, null: false

    field :region, Types::RegionType, null: false
    field :country, Types::CountryType, null: false

    field :events, [Types::EventType], null: false
    field :event_ids, [ID], null: false
    field :online_event_ids, [ID], null: false
    field :offline_event_ids, [ID], null: false

    def events
      object.events.publicly_visible.map { |venue| venue.extend(EventDecorator) }
    end

    def event_ids
      object.events.publicly_visible.pluck(:id)
    end

    def online_event_ids
      object.events.online.publicly_visible.pluck(:id)
    end

    def offline_event_ids
      object.events.offline.publicly_visible.pluck(:id)
    end

    def region
      object.region.extend(RegionDecorator)
    end

    def country
      object.country.extend(CountryDecorator)
    end
  end
end
