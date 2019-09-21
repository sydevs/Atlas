
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
    record.venue.manager == user || user.administrator?
  end

  def registrations?
    update?
  end
end
