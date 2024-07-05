module Types
  class LocationType < Types::BaseObject
    field :id, ID, null: false
    field :type, String, null: false
    # field :path, String, null: false, method: :map_path
    # field :url, String, null: false, method: :map_url
    
    field :name, String, null: true
    field :label, String, null: true
    field :latitude, Float, null: false
    field :longitude, Float, null: false
    field :radius, Float, null: true
    field :time_zone, String, null: false

    field :address, String, null: false
    field :directions_url, String, null: true

    field :events, [Types::EventType], null: false
    field :event_ids, [ID], null: false
    field :online_event_ids, [ID], null: false
    field :offline_event_ids, [ID], null: false

    field :area_id, ID, null: false

    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: false

    def area_id
      if self.class == Area
        id
      else
        area.id
      end
    end

    def type
      object.class.model_name
    end

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

    def radius
      object.try(:radius)
    end

    def directions_url
      object.try(:directions_url)
    end
  end
end
