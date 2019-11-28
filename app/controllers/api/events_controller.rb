class API::EventsController < API::ApplicationController

  prepend_before_action { @model = Event }

  def index
    params.reverse_merge!({ radius: 50 })
    records = nil

    if %i[north south east west].all? { |key| params.include?(key) }
      southwest = [params[:south], params[:west]]
      northeast = [params[:north], params[:east]]
      records = scope.joins(:venue, :pictures).in_bounds([southwest, northeast])
    elsif %i[latitude longitude].all? { |key| params.include?(key) }
      records = scope.joins(:venue, :pictures).within(params[:radius], origin: [params[:latitude], params[:longitude]])
    end

    if records.nil?
      super
    elsif records.present?
      super records
    elsif %i[latitude longitude].all? { |key| params.include?(key) }
      venue = scope.joins(:venue).select('venue_id, venues.city, venues.latitude, venues.longitude').first.venue
      @alternative = { label: "#{venue.city}, #{venue.country_code}", latitude: venue.latitude, longitude: venue.longitude }
      render 'api/views/empty'
    else
      super
    end
  end

end
