class DashboardPolicy < DatabasePolicy

  def show?
    user.present?
  end

  def update?
    false
  end

  def destroy?
    false
  end

  def index_association? association
    association = association.to_sym
    return false if %i[registrations pictures].include?(association)
    return false unless user.present?
    return false if user.type == :none
    return false if association == :regions && user.type == :event
    return true if %i[regions events].include?(association)

    user.administrator?
  end

  def new_association? association
    return nil if association == :events
    
    user.administrator? && %i[countries local_areas venues managers access_keys].include?(association)
  end

  def destroy_association? association = nil
    user.administrator? && %i[countries local_areas access_keys].include?(association)
  end

  def view_help?
    user.present?
  end

end
