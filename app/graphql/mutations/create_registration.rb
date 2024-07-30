require 'logger'

class Mutations::CreateRegistration < Mutations::BaseMutation
  null true

  argument :event_id, ID, required: true
  argument :name, String, required: true
  argument :email, String, required: true
  argument :questions, GraphQL::Types::JSON, required: false
  argument :starting_at, GraphQL::Types::ISO8601DateTime, required: true
  argument :time_zone, String, required: false
  argument :locale, String, required: false

  field :status, String, null: false
  field :message, String, null: false
  field :registration, Types::RegistrationType, null: true
  field :created_at, GraphQL::Types::ISO8601DateTime, null: true
  field :errors, [String], null: true

  def resolve(**arguments)
    I18n.locale = arguments[:locale]&.to_sym || :en
    event = Event.find(arguments[:event_id])
    time = event.recurrence.starts_at.to_fs(:time).split(':')
    arguments[:starting_at] = arguments[:starting_at].utc.change(hour: time[0].to_i, min: time[1].to_i)
    arguments[:questions] = arguments[:questions]
    arguments[:user_attributes] = { name: arguments[:name], email: arguments[:email] }
    arguments.except! :message, :locale, :name, :email

    user = User.find_by_email(arguments[:email])
    registration = event.registrations.find_or_initialize_by(user: user)

    if !registration.new_record? && !Rails.env.development?
      {
        status: 'info',
        message: I18n.translate('map.registration.feedback.duplicate'),
        created_at: registration.created_at.utc,
        registration: registration,
      }
    elsif registration.update(arguments)
      registration.subscribe_to! :registrations
      
      RegistrationMailer.with(registration: registration).confirmation.deliver_later
      RegistrationMailer.with(registration: registration).question.deliver_later if @registration.questions['questions'].present?
      BrevoAPI.schedule_reminder_email(registration)

      {
        status: 'success',
        message: I18n.translate('map.registration.feedback.success'),
        created_at: registration.created_at.utc,
        registration: registration,
      }
    else
      {
        status: 'error',
        message: registration.errors.full_messages.first
      }
    end
  rescue StandardError => error
    logger = Logger.new(STDOUT)
    logger.error error.message
    logger.error error.backtrace.join("\n")
    
    {
      status: 'error',
      message: I18n.translate('map.registration.feedback.error'),
      errors: [error.message],
    }
  end
end