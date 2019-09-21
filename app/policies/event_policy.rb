
class EventPolicy < DatabasePolicy
  def show?
    user.administrator? || record.managed_by?(user)
  end

  def create?
    user.administrator? || record.venue.managed_by?(user)
  end

  def update?
    user.administrator? || record.managed_by?(user)
  end

  def destroy?
    user.administrator? || record.managed_by?(user, super_manager: true)
  end

  def registrations?
    update?
  end
end
