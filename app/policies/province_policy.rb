class ProvincePolicy < PlacePolicy

  def update?
    false
  end

  def new_association? association = nil, query = {}
    return nil if association == :events
  
    %i[areas venues managers].include?(association) && super
  end

end
