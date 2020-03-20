class VenuePolicy < DatabasePolicy

  def geocode?
    manage?
  end

  def index_association? association = nil
    return false if association == :regions

    super association
  end

end
