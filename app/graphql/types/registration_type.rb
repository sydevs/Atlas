module Types
  class RegistrationType < Types::BaseObject
    field :id, ID, null: false
    field :event_id, Integer, null: true
    field :name, String, null: true
    field :email, String, null: true
    field :comment, String, null: true
    field :time_zone, String, null: true
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: false
    field :starting_at, GraphQL::Types::ISO8601DateTime, null: true
  end
end
