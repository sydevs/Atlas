module Types
  class VenueType < LocationType
    field :street, String, null: true
    field :city, String, null: true
    field :province, String, null: true, method: :province_name
    field :country, String, null: true, method: :country_name
    field :postcode, String, null: true

    field :place_id, String, null: true
  end
end
