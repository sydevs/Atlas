class API::VenuesController < API::ApplicationController

  def show
    @venue = decorate(Venue.find(params[:id]))
  end

end
