class CMS::RegistrationsController < CMS::ApplicationController

  prepend_before_action { @model = Registration }
  before_action :set_time_zone, only: :index

  def create
    return unless super(parameters)

    @record.touch(:latest_registration_at)
  end

  def update
    super parameters
  end

  private

    def set_time_zone
      return unless @context.is_a?(Event)

      @time_zone = @context.area.time_zone
    end

    def parameters
      params.fetch(:registration, {}).permit(
        :questions, :time_zone,
        user_attributes: %i[name email]
      )
    end

end
