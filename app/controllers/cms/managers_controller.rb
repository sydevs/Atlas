class CMS::ManagersController < CMS::ApplicationController

  prepend_before_action { @model = Manager }

  def create
    super parameters
  end

  def update
    super parameters
  end

  private

    def parameters
      params.fetch(:manager, {}).permit(
        :name, :email, :administrator,
        country_ids: [], province_ids: [], local_area_ids: []
      )
    end

end
