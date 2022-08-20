class VenuePolicy < DatabasePolicy

  def geocode?
    user.present?
  end

  def mappable?
    true
  end

end
