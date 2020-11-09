module Types
  class MutationType < Types::BaseObject
    field :create_registration, mutation: Mutations::CreateRegistration
  end
end
