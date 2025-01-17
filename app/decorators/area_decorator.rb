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
    Rails.application.routes.url_helpers.area_path(self)
  end

  def map_url
    Rails.application.routes.url_helpers.area_url(self, host: ENV.fetch('ATLAS_REACT_HOST'))
  end

end
