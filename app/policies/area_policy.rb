class AreaPolicy < RegionPolicy

  def geocode?
    user.present?
  end

  def mappable?
    true
  end

end
