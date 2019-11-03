class ProvincePolicy < RegionPolicy

  def update?
    false
  end

  def new_association? association = nil
    %i[local_areas managers venues].include?(association) && super
  end

end
