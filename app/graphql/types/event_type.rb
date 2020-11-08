module Types
  class EventType < Types::BaseObject
    field :id, ID, null: false
    field :path, String, null: false, method: :map_path
    field :url, String, null: false, method: :map_url

    field :label, String, null: false
    field :description, String, null: true
    field :category, String, null: false
    field :language, String, null: false, method: :language_name
    field :language_code, String, null: false, method: :language_code
    field :timing, Types::TimingType, null: false, resolver_method: :get_timing
    field :address, String, null: false

    field :online, Boolean, null: false
    field :online_url, String, null: true

    field :registration_mode, String, null: false
    field :registration_end_time, GraphQL::Types::ISO8601DateTime, null: false
    field :registration_url, String, null: true

    field :images, [Types::ImageType], null: true, resolver_method: :get_images

    field :venue_id, Integer, null: false
    field :venue, Types::VenueType, null: false, resolver_method: :get_venue

    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: false

    def get_venue
      object.venue.extend(VenueDecorator)
    end

    def get_timing
      {
        recurrence: object.recurrence,
        start_date: object.start_date.to_s,
        end_date: object.end_date&.to_s,
        start_time: object.start_time,
        end_time: object.end_time,
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
  end
end
