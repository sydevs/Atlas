module Types
  class EventContactType < Types::BaseObject
    field :phone_number, String, null: true
    field :phone_name, String, null: true

    field :email_address, String, null: true
    field :email_name, String, null: true

    field :meetup, String, null: true
    field :facebook, String, null: true
  end
end
