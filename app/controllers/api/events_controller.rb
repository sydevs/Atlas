class API::EventsController < API::ApplicationController

  prepend_before_action { @model = Event }

  def index
    if params[:latitude].present? && params[:longitude].present?
      super scope.joins(:venue).within(params[:radius] || 50, origin: [params[:latitude], params[:longitude]])
    else
      super
    end
  end

end
