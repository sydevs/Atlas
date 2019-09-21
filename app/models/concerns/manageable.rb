
module Manageable

  extend ActiveSupport::Concern

  included do
    belongs_to :manager, optional: :optional_manager?
  end
  
  def manager= params_or_manager
    if params_or_manager.is_a?(Hash)
      params = params_or_manager
      manager = Manager.find_or_initialize_by(email: params[:email])
      manager.name = params[:name] if params[:name].present?
      manager.save!
    else
      manager = params_or_manager
    end

    super manager
  end

  def optional_manager?
    is_a?(Event)
  end

end
