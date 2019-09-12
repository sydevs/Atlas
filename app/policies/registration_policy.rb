class RegistrationPolicy
  def create?
    true
  end

  def update?
    record.event.manager == user || record.event.venue.manager == user
  end
end
