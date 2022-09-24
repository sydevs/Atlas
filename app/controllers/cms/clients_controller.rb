class CMS::ClientsController < CMS::ApplicationController

  prepend_before_action { @model = Client }
  around_action :switch_locale

  def create
    super parameters.merge(secret_key: SecureRandom.uuid, public_key: SecureRandom.uuid)
  end

  def update
    super parameters
  end

  private

    def parameters
      params.fetch(:client, {}).permit(
        :label, :location_type, :location_id, :enabled,
        config: {},
        manager_attributes: %i[email name]
      )
    end

    def switch_locale(&action)
      I18n.with_locale(:en, &action)
    end

end
