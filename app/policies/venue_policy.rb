class VenuePolicy < DatabasePolicy

  def geocode?
    user.present?
  end

  def mappable?
    true
  end

  def index_association? association = nil
    return false if association == :regions

    super association
  end

end
