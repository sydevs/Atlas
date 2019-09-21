
class VenuePolicy < ApplicationPolicy
  def new?
    user.administrator? || user.regions.present?
  end

  def create?
    user.administrator? || record.managed_by?(user)
  end

  def update?
    user.administrator? || record.managed_by?(user)
  end

  def destroy?
    user.administrator? || record.managed_by?(user, super_manager: true)
  end
end
