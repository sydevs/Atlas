
class CountryPolicy < RegionPolicy

  def update?
    false
  end

  def new_association? association = nil
    %i[provinces local_areas managers].include?(association) && super
  end

end
