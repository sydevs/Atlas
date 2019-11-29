class WorldwidePolicy < DatabasePolicy

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
    return user.present? if association == :regions

    user.administrator?
  end

  def new_association? association
    return nil if %i[venues events].include?(association)
    
    user.administrator? && %i[countries local_areas managers access_keys].include?(association)
  end

  def destroy_association? association = nil
    user.administrator? && %i[countries local_areas access_keys].include?(association)
  end

end
