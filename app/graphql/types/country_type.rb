module Types
  class CountryType < Types::BaseObject
    field :id, ID, null: false
    
    field :label, String, null: true
    field :bounds, [Float], null: false
    
    field :venues, [Types::VenueType], null: false, resolver_method: :get_venues

    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: false

    def get_venues
      object.venues.publicly_visible.map { |venue| venue.extend(VenueDecorator) }
    end
  end
end
