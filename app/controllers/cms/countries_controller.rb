class CMS::CountriesController < CMS::ApplicationController

  prepend_before_action { @model = Country }

  def create
    super parameters
  end

  def update
    super parameters
  end

  def regions
    authorize_association! :regions

    @provinces = @context.provinces
    @local_areas = @context.local_areas.cross_province
    render 'cms/views/regions'
  end

  private

    def parameters
      params.fetch(:country, {}).permit(:country_code)
    end

end
