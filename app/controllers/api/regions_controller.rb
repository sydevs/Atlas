class API::RegionsController < API::ApplicationController

  def show
    region = Region.publicly_visible.includes(:areas).find(params[:id])
    @region = decorate(region)
  end

end
