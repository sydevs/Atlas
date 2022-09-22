module RegionDecorator

  def label
    "#{short_label}, #{country_code}"
  end

  def short_label
    translations[I18n.locale.to_s] || name
  end

  def map_path
    Rails.application.routes.url_helpers.map_region_path(self)
  end

  def map_url
    Rails.application.routes.url_helpers.map_region_url(self, layer: EventDecorator::LAYER[:offline], host: canonical_host)
  end

end
