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

  def map_path
    Rails.application.routes.url_helpers.map_area_path(self)
  end

  def map_url
    Rails.application.routes.url_helpers.map_area_url(self, layer: EventDecorator::LAYER[:offline], host: canonical_host)
  end

end
