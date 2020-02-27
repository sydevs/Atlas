class API::EventsController < API::ApplicationController

  prepend_before_action { @model = Event }

  def show
    super
  end

end
