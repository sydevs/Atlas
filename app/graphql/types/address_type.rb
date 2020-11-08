module Types
  class AddressType < Types::BaseObject
    field :room, String, null: true
    field :building, String, null: true
    field :street, String, null: true
    field :city, String, null: true
    field :province, String, null: true
    field :country, String, null: true
    field :postcode, String, null: true
  end
end
