module Types
  class VenueType < LocationType
    field :street, String, null: false
    field :city, String, null: false
    field :region_code, String, null: true
    field :country_code, String, null: false
    field :post_code, String, null: true
    field :place_id, String, null: true
  end
end
