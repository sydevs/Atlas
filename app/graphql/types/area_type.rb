module Types
  class AreaType < LocationType
    field :radius, Float, null: false
    field :online_event_ids, [ID], null: false, resolver_method: :get_online_event_ids

    def get_online_event_ids
      object.events.online.publicly_visible.pluck(:id)
    end
  end
end
