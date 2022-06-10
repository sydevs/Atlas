module Types
  class GeojsonFeatureType < Types::BaseObject
    field :type, String, null: false
    field :id, ID, null: false
    field :geometry, Types::GeojsonGeometryType, null: false
    field :properties, Types::LocationType, null: false
  end
end
