module Types
  class VenueType < LocationType
    field :street, String, null: false
    field :city, String, null: false
    field :region, String, null: true
    field :country_code, String, null: false
    field :post_code, String, null: true
    field :place_id, String, null: true

    field :area, Types::AreaType, null: false
    field :areas, [Types::AreaType], null: false
    field :area_id, ID, null: false

    def area
      object.areas.first.extend(AreaDecorator)
    end

    def area_id
      object.areas.first.id
    end

    def region
      object.parent.region.extend(RegionDecorator).short_label
    end
  end
end
