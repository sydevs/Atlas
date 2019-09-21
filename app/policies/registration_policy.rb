
class RegistrationPolicy < DatabasePolicy
  def new?
    false
  end

  def create?
    true
  end

  def update?
    user.administrator? || record.event.managed_by?(user)
  end
end
