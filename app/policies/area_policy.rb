class AreaPolicy < PlacePolicy

  def geocode?
    user.present?
  end

  def mappable?
    true
  end

end
