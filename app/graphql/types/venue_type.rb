module Types
  class VenueType < LocationType
    field :street, String, null: true
    field :place_id, String, null: true
  end
end
