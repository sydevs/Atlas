require 'logger'

class Mutations::CreateRegistration < Mutations::BaseMutation
  null true

  argument :event_id, ID, required: true
  argument :name, String, required: true
  argument :email, String, required: true
  argument :message, String, required: false
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
    time = event.start_time.split(':')
    arguments[:starting_at] = arguments[:starting_at].utc.change(hour: time[0].to_i, min: time[1].to_i)
    arguments[:comment] = arguments[:message]
    arguments.delete :message
    arguments.delete :locale

    registration = Registration.joins(:event).find_or_initialize_by(arguments)

    if !registration.new_record?
      {
        status: 'info',
        message: I18n.translate('map.registration.feedback.duplicate'),
        created_at: registration.created_at.utc,
        registration: registration,
      }
    elsif registration.save
      registration = registration.extend(RegistrationDecorator)
      event = registration.event.extend(EventDecorator)

      SendinblueAPI.subscribe(registration.email, SendinblueAPI::LISTS[:registrations], {
        email: registration.email,
        firstname: registration.first_name,
        lastname: registration.last_name,
      })

      SendinblueAPI.send_email({
        sender: { name: 'We Meditate', email: 'admin@wemeditate.com' },
        to: [{ name: registration.name, email: registration.email }],
        subject: "Registratin Confirmed - #{registration.event.label}",
        templateId: SendinblueAPI::TEMPLATES[:confirmation],
        params: {
          url: event.map_url,
          label: event.label,
          address: event.address,
          timing: [event.start_time, event.end_time].compact.join(' - '),
          date: registration.starting_date.to_s(:short),
          weekday: registration.starting_at_weekday.upcase,
          directions_url: event.decorated_venue&.directions_url
        },
        tags: %w[atlas],
      })
      
      if registration.starting_at > 1.day.from_now
        SendinblueAPI.send_email({
          scheduledAt: (registration.starting_at - 1.day).utc.iso8601,
          sender: { name: 'We Meditate', email: 'admin@wemeditate.com' },
          to: [{ name: registration.name, email: registration.email }],
          subject: "Starting Soon - #{registration.event.label}",
          templateId: SendinblueAPI::TEMPLATES[:confirmation],
          params: {
            url: event.map_url,
            label: event.label,
            address: event.address,
            timing: [event.start_time, event.end_time].compact.join(' - '),
            date: registration.starting_date.to_s(:short),
            weekday: registration.starting_at_weekday.upcase,
            directions_url: event.decorated_venue&.directions_url
          },
          tags: %w[atlas reminder],
        })
      end

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