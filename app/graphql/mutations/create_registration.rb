class Mutations::CreateRegistration < Mutations::BaseMutation
  null true

  argument :event_id, ID, required: true
  argument :name, String, required: true
  argument :email, String, required: true
  argument :starting_at, GraphQL::Types::ISO8601DateTime, required: true

  field :registration, Types::RegistrationType, null: true
  field :errors, [String], null: false

  def resolve(event_id:, **kwargs)
    event = Event.find(event_id)
    registration = event.registrations.build(kwargs)

    if registration.save
      # Successful creation, return the created object with no errors
      {
        registration: registration,
        errors: [],
      }
    else
      # Failed save, return the errors to the client
      {
        registration: nil,
        errors: registration.errors.full_messages
      }
    end
  end
end