class WorldwidePolicy < DatabasePolicy

  def manage?
    user.present? && user.administrator?
  end

  def show?
    false
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
    return false if %i[regions areas].include?(association)

    manage?
  end

  def new_association? association, query = {}
    return nil if association == :events
    
    manage? && %i[countries areas venues managers clients].include?(association)
  end

  def destroy_association? association = nil
    manage? && %i[countries areas clients].include?(association)
  end

end
