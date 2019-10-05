class CMS::LocalAreasController < CMS::ApplicationController

  prepend_before_action { @model = LocalArea }

  def create
    super parameters
  end

  def update
    super parameters
  end

  private

    def parameters
      params.fetch(:local_area, {}).permit(
        :name, :identifier, :country_code, :province_code,
        :latitude, :longitude, :radius, :restriction
      )
    end

end
