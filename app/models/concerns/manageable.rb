
module Manageable

  extend ActiveSupport::Concern

  included do
    has_many :managed_records, as: :record
    has_many :managers, through: :managed_records
  end

  def managed_by? manager, super_manager: false
    return true if !super_manager && managers.include?(manager)
    return parent.managed_by?(manager) if respond_to?(:parent) && parent.respond_to?(:managed_by?)
    return false
  end

  def parent_managers
    @parent_managers ||= (respond_to?(:parent) && parent.present? ? parent.all_managers : [])
  end

  def all_managers
    @all_managers ||= begin
      result = managers.to_a
      result += parent.all_managers if respond_to?(:parent) && parent.present?
      result
    end
  end
  
  def add_manager params_or_manager
    if params_or_manager.is_a?(Hash)
      params = params_or_manager
      manager = Manager.find_or_initialize_by(email: params[:email])
      manager.name = params[:name] if params[:name].present?
      manager.save!
    else
      manager = params_or_manager
    end

    managers << manager
  end

end
