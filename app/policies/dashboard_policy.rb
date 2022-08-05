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
    return false if %i[managed_records registrations pictures].include?(association)
    return false unless user.present?
    return false if user.type == :none
    return true if association == :events

    user.administrator?
  end

  def new_association? association, query = {}
    return nil if association == :events
    
    user.administrator? && %i[countries areas venues managers clients].include?(association)
  end

  def destroy_association? association = nil
    user.administrator? && %i[countries areas clients].include?(association)
  end

  def view_help?
    user.present?
  end

end
