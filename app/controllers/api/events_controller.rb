class API::EventsController < API::ApplicationController

  prepend_before_action { @model = Event }

  def index
    params.reverse_merge!({ radius: 50 })
    coordinates = [params[:latitude], params[:longitude]]

    if %i[north south east west].all? { |key| params.include?(key) }
      southwest = [params[:south], params[:west]]
      northeast = [params[:north], params[:east]]
      query = scope.by_distance(origin: coordinates) if %i[latitude longitude].all? { |key| params.include?(key) }
      records = query.joins(:venue).includes(:pictures).in_bounds([southwest, northeast])
    elsif %i[latitude longitude].all? { |key| params.include?(key) }
      records = scope.joins(:venue).includes(:pictures).within(params[:radius], origin: coordinates)
    else
      super && return
    end

    if records.present?
      super records
    elsif %i[latitude longitude].all? { |key| params.include?(key) }
      query = scope.by_distance(origin: coordinates)
      events = query.joins(:venue).select('events.venue_id, venues.city, venues.latitude, venues.longitude').limit(10)

      @alternatives = events.map do |event|
        venue = event.venue
        {
          label: "#{venue.city}, #{venue.country_code}",
          latitude: venue.latitude,
          longitude: venue.longitude,
          distance: venue.distance_from(coordinates),
        }
      end

      render 'api/views/empty'
    else
      super
    end
  end

end
