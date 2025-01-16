class API::RegionsController < API::ApplicationController

  def show
    region = Region.find(params[:id]).includes(:areas)
    @region = decorate(region)
  end

end
