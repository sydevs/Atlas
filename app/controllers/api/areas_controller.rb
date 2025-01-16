class API::AreasController < API::ApplicationController

  def show
    area = Area.find(params[:id]).includes(:events)
    @area = decorate(area)
  end

end
