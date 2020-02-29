module VenueDecorator

  def label
    name || street
  end

  def full_address
    @full_address ||= [street, city, province_name, country_code].compact.join(', ')
  end

  def address
    {
      building: name,
      street: street,
      city: city,
      province: province_code,
      country: country_code,
      postcode: postcode,
    }
  end

  def province_name
    ProvinceDecorator.get_name(province_code, country_code)
  end

  def country_name
    CountryDecorator.get_label(country_code)
  end

  def distance(coordinates)
    @distance ||= distance_from(coordinates)
  end

  def distance_in_words(coordinates)
    I18n.translate('api.distance', distance: distance(coordinates).to_i)
  end

end
