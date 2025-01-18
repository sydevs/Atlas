class API::AreasController < API::ApplicationController

  def show
    area = Area.publicly_visible.includes(:events).find(params[:id])
    @area = decorate(area)
  end

end
