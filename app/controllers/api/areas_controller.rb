class API::AreasController < API::ApplicationController

  def show
    area = Area.includes(:events).find(params[:id])
    @area = decorate(area)
  end

end
