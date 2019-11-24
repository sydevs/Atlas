class API::EventsController < API::ApplicationController

  prepend_before_action { @model = Event }

  def index
    params.reverse_merge!({
      radius: 50,
    })

    if %i[latitude longitude].all? { |key| params.include?(key) }
      super scope.joins(:venue).within(params[:radius], origin: [params[:latitude], params[:longitude]])
    elsif %i[north south east west].all? { |key| params.include?(key) }
      southwest = [params[:south], params[:west]]
      northeast = [params[:north], params[:east]]
      super scope.joins(:venue).in_bounds([southwest, northeast])
    else
      super
    end
  end

end
