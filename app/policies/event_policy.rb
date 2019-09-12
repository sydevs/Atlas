
class EventPolicy < ApplicationPolicy
  def show?
    true
  end

  def create?
    record.venue.manager == user
  end

  def update?
    record.manager == user || record.venue.manager == user
  end

  def destroy?
    false
  end

  def registrations?
    update?
  end
end
