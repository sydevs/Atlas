
class ManagerPolicy < ApplicationPolicy
  def create?
    user.administrator?
  end

  def update?
    record.manager == user || user.administrator?
  end

  def destroy?
    user.administrator?
  end
end
