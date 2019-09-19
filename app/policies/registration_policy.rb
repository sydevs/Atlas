
class RegistrationPolicy < ApplicationPolicy
  def create?
    true
  end

  def update?
    user.administrator? || record.event.managed_by?(user)
end
