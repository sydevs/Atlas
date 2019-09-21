class CMS::EventsController < CMS::ApplicationController

  prepend_before_action { @model = Event }

  def create
    super parameters
  end

  def update
    super parameters
  end

  private

    def parameters
      params.fetch(:event, {}).permit(
        :name, :description, :room, :category,
        :recurrence, :start_date, :end_date, :start_time, :end_time,
        manager: {},
        languages: [],
      )
    end

end
