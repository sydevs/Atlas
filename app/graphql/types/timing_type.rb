module Types
  class TimingType < Types::BaseObject
    field :start_date, GraphQL::Types::ISO8601Date, null: false
    field :end_date, GraphQL::Types::ISO8601Date, null: true
    field :start_time, String, null: false
    field :end_time, String, null: true
    field :recurrence, String, null: false
    field :duration, Float, null: true
    field :time_zone, String, null: false
  end
end
