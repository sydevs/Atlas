
class RegionPolicy < DatabasePolicy
  def show?
    true
  end

  def index?
    true
  end

  def create?
    user.administrator? || record.managed_by?(user, super_manager: true)
  end

  def update?
    user.administrator? || record.managed_by?(user, super_manager: true)
  end

  def destroy?
    user.administrator? || record.managed_by?(user, super_manager: true)
  end
end
