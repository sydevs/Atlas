module Types
  class EventType < Types::BaseObject
    field :id, ID, null: false
    field :path, String, null: false, method: :map_path
    field :url, String, null: false, method: :map_url
    field :status, String, null: false
    field :layer, String, null: false, resolver_method: :get_layer

    field :label, String, null: false
    field :description, String, null: true
    field :category, String, null: false
    field :language, String, null: false, method: :language_name
    field :language_code, String, null: false, method: :language_code
    field :address, String, null: false

    field :timing, Types::TimingType, null: false, resolver_method: :get_timing

    field :phone_number, String, null: true
    field :phone_name, String, null: true

    field :online, Boolean, null: false
    field :online_url, String, null: true

    field :registration_mode, String, null: false
    field :registration_end_time, GraphQL::Types::ISO8601DateTime, null: true
    field :registration_url, String, null: true
    field :registration_count, Integer, null: true, resolver_method: :registration_count
    field :registration_limit, Integer, null: true

    field :images, [Types::ImageType], null: true, resolver_method: :get_images

    field :location_id, Integer, null: false
    field :location_type, Integer, null: false
    field :location, Types::LocationType, null: false, resolver_method: :get_location
    field :venue, Types::VenueType, null: false, resolver_method: :get_venue
    field :area, Types::LocalAreaType, null: false, resolver_method: :get_area

    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: false

    def get_location
      object.location.extend("#{object.location_type}Decorator".constantize)
    end

    def get_venue
      object.venue.extend(VenueDecorator)
    end

    def get_area
      object.local_area.extend(LocalAreaDecorator)
    end

    def get_timing
      {
        first_date: object.next_occurrences_after(object.start_date, limit: 1).first,
        last_date: object.registration_end_time ? object.next_occurrences_after(object.registration_end_time, limit: 1).first : nil,
        upcoming_dates: object.next_occurrences_after(Time.now, limit: 7),

        start_time: object.start_time,
        end_time: object.end_time,

        recurrence: object.recurrence,
        duration: object.duration,
        time_zone: object.time_zone,
      }
    end

    def get_occurrences
      {
        first: object.next_occurrences_after(object.start_date, limit: 1).first,
        last: object.registration_end_time ? object.next_occurrences_after(object.registration_end_time, limit: 1).first : null,
        upcoming: object.next_occurrences_after(Time.now, limit: 7),
      }
    end

    def get_images
      object.pictures.map { |picture|
        {
          url: picture.file.url,
          thumbnail_url: picture.file.url(:thumbnail),
        }
      }
    end

    def get_layer
      object.online? ? 'online' : 'offline'
    end

    def registration_count
      object.registrations.count
    end
  end
end
