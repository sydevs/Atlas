module Types
  class GeojsonGeometryType < Types::BaseObject
    field :type, String, null: false
    field :coordinates, [Float], null: false
  end
end
