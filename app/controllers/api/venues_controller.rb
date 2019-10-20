class API::VenuesController < API::ApplicationController

  prepend_before_action { @model = Venue }

  def index
    if params[:latitude].present? && params[:longitude].present?
      super scope.within(params[:radius] || 500, origin: [params[:latitude], params[:longitude]])
    else
      super
    end
  end

end
