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

    @provinces = @context.provinces if @context.enable_province_management?
    @local_areas = @context.local_areas.cross_province
    render 'cms/views/regions'
  end

  private

    def parameters
      params.fetch(:country, {}).permit(:country_code, :default_language_code, :enable_province_management, :bounds)
    end

end
