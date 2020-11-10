module Types
  class GeojsonType < Types::BaseObject
    field :type, String, null: false
    field :features, [Types::GeojsonFeatureType], null: false
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
  end
end
