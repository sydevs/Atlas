class CountryPolicy < RegionPolicy

  def update?
    false
  end

  def new_association? association = nil
    return nil if %i[venues events].include?(association)
    
    %i[provinces local_areas managers].include?(association) && super
  end

end
