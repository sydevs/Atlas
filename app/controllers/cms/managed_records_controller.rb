class CMS::ManagedRecordsController < CMS::ApplicationController

  prepend_before_action { @model = ManagedRecord }

  skip_after_action :verify_policy_scoped, only: %i[index]

  def index
    authorize_association! @model
  end

end
