module Types
  class RegistrationType < Types::BaseObject
    field :id, ID, null: false
    field :event_id, Integer, null: false
    field :name, String, null: false
    field :first_name, String, null: false
    field :last_name, String, null: true
    field :email, String, null: false
    field :comment, String, null: true
    field :time_zone, String, null: true
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: false
    field :starting_at, GraphQL::Types::ISO8601DateTime, null: true
    field :starting_date, GraphQL::Types::ISO8601Date, null: true

    def first_name
      object.name.split(' ', 2).first
    end

    def last_name
      split = object.name.split(' ', 2)
      split.last if split.length > 1
    end

    def starting_date
      object.starting_at
    end
  end
end
