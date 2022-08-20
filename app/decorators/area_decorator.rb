module AreaDecorator

  def label
    if country_code?
      "#{name}, #{CountryDecorator.get_short_label(country_code)}"
    else
      name
    end
  end

  def short_label
    name
  end

  def address
    label
  end

  def region_name
    region.name
  end

  def country_name format = :full
    return nil unless country_code

    format == :short ? CountryDecorator.get_short_label(country_code) : CountryDecorator.get_label(country_code)
  end

  def map_path
    Rails.application.routes.url_helpers.map_area_path(self)
  end

  def map_url
    Rails.application.routes.url_helpers.map_area_url(self)
  end

end
