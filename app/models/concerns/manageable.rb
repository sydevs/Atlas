module Manageable

  extend ActiveSupport::Concern

  included do
    has_many :managed_records, as: :record
    has_many :managers, through: :managed_records, dependent: :destroy
  end

  def managed_by? manager, super_manager: false
    return true if !super_manager && managers.include?(manager)
    return parent.managed_by?(manager) if respond_to?(:parent) && parent.respond_to?(:managed_by?)

    false
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

end
