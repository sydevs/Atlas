module Types
  class TimingType < Types::BaseObject
    field :first_date, GraphQL::Types::ISO8601DateTime, null: false
    field :last_date, GraphQL::Types::ISO8601DateTime, null: true
    field :upcoming_dates, [GraphQL::Types::ISO8601DateTime], null: false

    field :start_time, String, null: false
    field :end_time, String, null: true

    field :recurrence, String, null: false
    field :duration, Float, null: true
    field :time_zone, String, null: false
  end
end
