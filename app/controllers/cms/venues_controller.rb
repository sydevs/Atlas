class CMS::VenuesController < CMS::ApplicationController

  prepend_before_action { @model = Venue }

  def create
    super parameters
  end

  def update
    super parameters
  end

  private

    def parameters
      params.fetch(:venue, {}).permit(
        :name, :category, :latitude, :longitude,
        :street, :city, :province_name, :country_code,
        manager: {}
      )
    end

end
