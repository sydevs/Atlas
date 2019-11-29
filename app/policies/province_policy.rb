class ProvincePolicy < RegionPolicy

  def update?
    false
  end

  def new_association? association = nil
    return nil if association == :events
  
    %i[local_areas venues managers].include?(association) && super
  end

end
