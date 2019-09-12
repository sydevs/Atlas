
class VenuePolicy < ApplicationPolicy
  def create?
    false
  end

  def update?
    record.manager == user
  end

  def destroy?
    false
  end
end
