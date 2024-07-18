module Types
  class EventTimingType < Types::BaseObject
    field :first_date, GraphQL::Types::ISO8601DateTime, null: true
    field :last_date, GraphQL::Types::ISO8601DateTime, null: true
    field :upcoming_dates, [GraphQL::Types::ISO8601DateTime], null: false
    field :recurrence_count, Integer, null: true

    field :start_time, String, null: true
    field :end_time, String, null: true

    field :recurrence, String, null: true
    field :duration, Float, null: true
    field :time_zone, String, null: false
  end
end
