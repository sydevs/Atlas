class ManagerPolicy
  def create?
    record.venue.manager == user
  end

  def update?
    record.manager == user # || user.administrator?
  end

  def destroy?
    false
  end
end
