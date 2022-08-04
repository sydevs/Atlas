class CountryPolicy < RegionPolicy

  def new_association? association = nil, query = {}
    return nil if association == :events
    
    %i[provinces areas venues managers].include?(association) && super
  end

  def index_association? association = nil
    return false if association == :areas

    super
  end

end
