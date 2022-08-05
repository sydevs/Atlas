class CMS::RegionsController < CMS::ApplicationController

  prepend_before_action { @model = Region }

  def create
    super parameters
  end

  def update
    super parameters
  end

  private

    def parameters
      params.fetch(:region, {}).permit(:country_code, :name, :osm_id)
    end

end
