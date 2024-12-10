class API::AreasController < API::ApplicationController

  def show
    @area = decorate(Area.find(params[:id]))
  end

end
