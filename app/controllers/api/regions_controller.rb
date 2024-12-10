class API::RegionsController < API::ApplicationController

  def show
    @region = decorate(Region.find(params[:id]))
  end

end
