class API::VenuesController < API::ApplicationController

  def show
    venue = Venue.find(params[:id]).includes(:events)
    @venue = decorate(venue)
  end

end
