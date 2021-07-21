class CMS::ClientsController < CMS::ApplicationController

  prepend_before_action { @model = Client }

  def create
    super parameters.merge(secret_key: SecureRandom.uuid, public_key: SecureRandom.uuid)
  end

  def update
    super parameters
  end

  private

    def parameters
      params.fetch(:client, {}).permit(
        :label, :domain, :enabled,
        config: {},
        manager_attributes: %i[email name]
      )
    end

end
