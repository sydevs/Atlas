
class ManagerPolicy < DatabasePolicy
  def show?
    user.administrator?
  end

  def index?
    user.administrator?
  end

  def new?
    user.administrator? || user.countries.present? || user.provinces.present?
  end

  def create?
    user.administrator? || record.managed_by?(user)
  end

  def update?
    user.administrator? || record.managed_by?(user)
  end

  def destroy?
    user.administrator?
  end
end
