class API::EventsController < API::ApplicationController

  prepend_before_action { @model = Event }

  def index
    if params[:latitude].present? && params[:longitude].present?
      super scope.joins(:venue).within(params[:radius] || 50, origin: [params[:latitude], params[:longitude]])
    elsif params[:from_bounds]
      south_west_point = [params[:south_west_point_lat], params[:south_west_point_lng]]
      north_east_point = [params[:north_east_point_lat], params[:north_east_point_lng]]
      super scope.joins(:venue).in_bounds([south_west_point, north_east_point], origin: [params[:latitude], params[:longitude]])
    else
      super
    end
  end

end
