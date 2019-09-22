class CMS::ProvincesController < CMS::ApplicationController

  prepend_before_action { @model = Province }

  def create
    super parameters
  end

  def update
    super parameters
  end

  private

    def parameters
      params.fetch(:province, {}).permit(:country_code, :province_code)
    end

end
