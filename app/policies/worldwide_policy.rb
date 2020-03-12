class WorldwidePolicy < DatabasePolicy

  def show?
    user.present? && user.administrator?
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

    show?
  end

  def new_association? association
    return nil if association == :events
    
    show? && %i[countries local_areas venues managers access_keys].include?(association)
  end

  def destroy_association? association = nil
    show? && %i[countries local_areas access_keys].include?(association)
  end

end
