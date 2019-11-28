class API::EventsController < API::ApplicationController

  prepend_before_action { @model = Event }

  def index
    params.reverse_merge!({ radius: 50 })

    if %i[latitude longitude].all? { |key| params.include?(key) }
      records = scope.joins(:venue).within(params[:radius], origin: [params[:latitude], params[:longitude]])

      if records.present?
        super records
      else
        venue = scope.joins(:venue).select('venue_id, venues.city, venues.latitude, venues.longitude').first.venue
        @alternative = { label: "#{venue.city}, #{venue.country_code}", latitude: venue.latitude, longitude: venue.longitude }
        render 'api/views/empty'
      end
    elsif %i[north south east west].all? { |key| params.include?(key) }
      southwest = [params[:south], params[:west]]
      northeast = [params[:north], params[:east]]
      super scope.joins(:venue).in_bounds([southwest, northeast])
    else
      super
    end
  end

end
