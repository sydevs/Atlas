module Types
  class VenueType < LocationType
    field :street, String, null: true
    field :city, String, null: true
    field :region, String, null: true, method: :region_name
    field :country, String, null: true, method: :country_name
    field :postcode, String, null: true

    field :place_id, String, null: true
  end
end
