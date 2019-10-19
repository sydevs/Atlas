
class DatabasePolicy < ApplicationPolicy

  def manage? super_manager: false
    user.administrator? || record.managed_by?(user, super_manager: super_manager)
  end

  def show?
    manage?
  end

  def new?
    user.present?
  end

  def create?
    manage? super_manager: true
  end

  def update?
    manage?
  end

  def destroy?
    manage? super_manager: true
  end

  def index_association? association = nil
    return record.has_region_association? if association == :regions
    return false unless manage?
    return record.respond_to?(association)
  end

  def new_association? association = nil
    return false if association == :audits
    return record.respond_to?(association) && manage?
  end

  def destroy_association? association = nil
    user.administrator? && association == :managers
  end
end
