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

      venue = @context.venue
      @time_zone = Timezone.lookup(venue.latitude, venue.longitude)
    end

    def parameters
      params.fetch(:registration, {}).permit(:name, :email, :comment)
    end

end
