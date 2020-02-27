class API::VenuesController < API::ApplicationController

  prepend_before_action { @model = Venue }

  def show
    super
  end

  def index
    params.reverse_merge!({ radius: 50 })
    @coordinates = [params[:latitude], params[:longitude]]
    @type = params[:type] || 'area'

    if %i[north south east west].all? { |key| params.include?(key) }
      southwest = [params[:south], params[:west]]
      northeast = [params[:north], params[:east]]
      query = scope.by_distance(origin: @coordinates) if %i[latitude longitude].all? { |key| params.include?(key) }
      records = query.in_bounds([southwest, northeast])
    elsif %i[latitude longitude].all? { |key| params.include?(key) }
      records = scope.within(params[:radius], origin: @coordinates).by_distance(origin: @coordinates)
    else
      super && return
    end

    if records.present?
      records = records.includes(:events, events: :pictures) if @verbose
      super records.includes(:events, events: :pictures)
    elsif %i[latitude longitude].all? { |key| params.include?(key) }
      query = scope.by_distance(origin: @coordinates)
      venues = query.select('id, city, country_code, latitude, longitude').limit(10)

      @alternatives = venues.map do |venue|
        {
          label: "#{venue.city}, #{venue.country_code}",
          latitude: venue.latitude,
          longitude: venue.longitude,
          distance: venue.distance_from(@coordinates),
        }
      end

      render 'api/views/empty'
    else
      super
    end
  end

end
