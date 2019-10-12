module VenueDecorator

  def label
    name || street
  end

  def full_address
    [street, city, province_code, country_code].compact.join(', ')
  end

  def address
    {
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

end
