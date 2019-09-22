
class LocalAreaPolicy < RegionPolicy

  def new_association? association = nil
    %i[managers venues].include?(association) && super
  end

end
