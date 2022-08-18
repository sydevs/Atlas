module VenueDecorator

  def label
    name || street
  end

  def directions_url
    if place_id?
      "https://www.google.com/maps/search?api=1&query=#{address}&query_place_id=#{place_id}"
    else
      "http://www.google.com/maps/place/#{latitude},#{longitude}"
    end
  end

  def region_name
    RegionDecorator.get_name(province_code, country_code) if province_code && country_code
  end

  def country_name format = :full
    return nil unless country_code

    format == :short ? CountryDecorator.get_short_label(country_code) : CountryDecorator.get_label(country_code)
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
    Rails.application.routes.url_helpers.map_venue_url(self)
  end

end
