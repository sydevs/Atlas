module VenueDecorator

  def label
    name || street
  end

  def address
    # components = (country.enable_regions? ? [street, city, region_code, country_code] : [street, city, country_code])
    components = [street, city, region_code, country_code]
    components.compact.join(', ')
  end

  def directions_url
    if place_id?
      "https://www.google.com/maps/dir/?api=1&destination=#{address}&destination_place_id=#{place_id}"
    else
      "http://www.google.com/maps/place/#{latitude},#{longitude}"
    end
  end

  def distance(coordinates)
    @distance ||= distance_from(coordinates)
  end

  def distance_in_words(coordinates)
    I18n.translate('api.distance', distance: distance(coordinates).to_i)
  end

  def map_path
    Rails.application.routes.url_helpers.map_venue_path(self)
  end

  def map_url
    Rails.application.routes.url_helpers.map_venue_url(self, layer: EventDecorator::LAYER[:offline], host: canonical_host)
  end

end
