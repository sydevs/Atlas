class PlacePolicy < DatabasePolicy

  def show?
    true
  end

  def index?
    true
  end

  def update?
    manage? super_manager: true
  end

  def search?
    false
  end

  def index_association? association = nil
    return false if association == :registrations
    
    super
  end

end
