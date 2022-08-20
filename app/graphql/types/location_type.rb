module Types
  class LocationType < Types::BaseObject
    field :id, ID, null: false
    # field :path, String, null: false, method: :map_path
    # field :url, String, null: false, method: :map_url
    
    field :label, String, null: true
    field :latitude, Float, null: false
    field :longitude, Float, null: false
    field :time_zone, String, null: false
    
    field :address, String, null: false
    field :directions_url, String, null: true, resolver_method: :get_directions_url

    field :events, [Types::EventType], null: false, resolver_method: :get_events
    field :event_ids, [ID], null: false, resolver_method: :get_event_ids

    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: false

    def get_events
      object.events.publicly_visible.map { |event| event.extend(EventDecorator) }
    end

    def get_event_ids
      object.events.publicly_visible.pluck(:id)
    end

    def get_directions_url
      object.try(:directions_url)
    end
  end
end
