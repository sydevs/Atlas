require 'rails_autolink'

module Types
  class EventType < Types::BaseObject
    include LocalizationHelper

    field :id, ID, null: false
    field :path, String, null: false, method: :map_path
    field :url, String, null: false, method: :map_url
    
    field :status, String, null: false
    field :layer, String, null: false
    field :type, String, null: false

    field :label, String, null: false
    field :description, String, null: true
    field :description_html, String, null: true, method: :description_html
    field :category, String, null: false
    field :language, String, null: false, method: :language_name
    field :language_code, String, null: false
    field :address, String, null: false

    field :timing, Types::EventTimingType, null: false
    field :contact, Types::EventContactType, null: false, method: :contact_info

    field :online, Boolean, null: false, method: :online?
    field :online_url, String, null: true

    field :registrations, [Types::RegistrationType], null: false
    field :registration_mode, String, null: false
    field :registration_end_time, GraphQL::Types::ISO8601DateTime, null: true
    field :registration_url, String, null: true
    field :registration_count, Integer, null: true
    field :registration_limit, Integer, null: true
    field :registration_questions, [RegistrationQuestionType], null: true

    field :images, [Types::ImageType], null: true

    field :area_id, ID, null: false
    
    field :venue, Types::VenueType, null: false
    field :area, Types::AreaType, null: false
    field :location, Types::LocationType, null: false

    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: false

    def location
      object.location.extend("#{object.location.class}Decorator".constantize)
    end

    def venue
      object.venue.extend(VenueDecorator)
    end

    def area
      object.area.extend(AreaDecorator)
    end

    def description_html
      helpers = ActionController::Base.helpers
      description = helpers.simple_format object.description
      helpers.auto_link(description, link: :urls, html: { target: '_blank', rel: 'nofollow' }) do |text|
        text = text.delete_prefix("http://").delete_prefix("https://").delete_prefix("www.")
        text = text.split("/", 2)
        text[1] = helpers.truncate(text[1], length: 15) if text.count > 1
        text.join("/")
      end
    end

    def timing
      {
        first_date: object.first_recurrence_at,
        last_date: object.last_recurrence_at,
        upcoming_dates: object.upcoming_recurrences(limit: 7),
        recurrence_count: object.recurrence&.finite? ? object.recurrence.events.to_a.count : nil,

        start_time: object.recurrence&.starts_at&.to_s(:time),
        end_time: object.recurrence&.ends_at&.to_s(:time),

        recurrence: object.recurrence_type,
        duration: object.duration,
        time_zone: object.time_zone,
      }
    end

    def images
      object.pictures.map { |picture|
        {
          url: picture.file.url,
          thumbnail_url: picture.file.url(:thumbnail),
        }
      }
    end

    def registration_count
      object.registrations.count
    end

    def registration_questions
      object.registration_question.map do |question|
        {
          slug: question,
          title: translate_enum_value(Event, :registration_question, question),
        }
      end
    end
  end
end
