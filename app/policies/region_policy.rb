
class RegionPolicy < DatabasePolicy

  def show?
    true
  end

  def index?
    true
  end

  def update?
    manage? super_manager: true
  end

end
