class VenuePolicy < DatabasePolicy

  def geocode?
    manage?
  end

end
