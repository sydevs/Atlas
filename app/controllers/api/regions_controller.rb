class API::RegionsController < API::ApplicationController

  def show
    region = Region.includes(:areas).find(params[:id])
    @region = decorate(region)
  end

end
