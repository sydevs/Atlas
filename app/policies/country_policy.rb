class CountryPolicy < RegionPolicy

  def update?
    false
  end

  def new_association? association = nil
    return nil if association == :events
    
    %i[provinces local_areas venues managers].include?(association) && super
  end

end
