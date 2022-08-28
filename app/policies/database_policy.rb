class DatabasePolicy < ApplicationPolicy

  def manage? super_manager: nil
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

  def create_manager?
    new_association?(:managers)
  end

  def index_association? association = nil
    return false unless manage?
    return false if association == :managed_records

    record.respond_to?(association)
  end

  def new_association? association = nil, query = {}
    return false if association == :audits

    record.respond_to?(association) && manage?
  end

  def destroy_association? association = nil
    return true if manage? && association == :managers
    return true if update? && association == :pictures

    false
  end

  def search?
    index?
  end

  def geosearch?
    user.present?
  end

end
