class API::VenuesController < API::ApplicationController

  def show
    venue = Venue.includes(:events).find(params[:id])
    @venue = decorate(venue)
  end

end
