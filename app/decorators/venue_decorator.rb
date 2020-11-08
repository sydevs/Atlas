module VenueDecorator

  def label
    name || street
  end

  def location_label
    "#{city || province || street || name}, #{translate country.downcase, scope: 'map.short_country_names', default: country_code}"
  end

  def address
    @address ||= [street, city, province, country].compact.join(', ')
  end

  def directions_url
    if place_id?
      "https://www.google.com/maps/search/?api=1&query=#{address}>&query_place_id=#{place_id}"
    else
      "http://www.google.com/maps/place/#{latitude},#{longitude}"
    end
  end

  def province
    ProvinceDecorator.get_name(province_code, country_code) if province_code && country_code
  end

  def country
    CountryDecorator.get_label(country_code) if country_code
  end

  def distance(coordinates)
    @distance ||= distance_from(coordinates)
  end

  def distance_in_words(coordinates)
    I18n.translate('api.distance', distance: distance(coordinates).to_i)
  end

  def as_json(_context = nil)
    {
      id: id,
      label: label,
      latitude: latitude,
      longitude: longitude,
      directions_url: directions_url,
      events: events.publicly_visible.map { |event| event.extend(EventDecorator).as_json },
    }
  end

end
