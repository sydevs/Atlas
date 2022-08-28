module CountryDecorator

  def label
    translations[I18n.locale.to_s] || name || CountryDecorator.get_label(country_code)
  end

  def short_label
    CountryDecorator.get_short_label(country_code)
  end

  def self.get_label country_code
    ISO3166::Country.translations[country_code]
  end

  def self.get_short_label country_code
    I18n.translate(country_code.downcase, scope: 'cms.country_codes', default: country_code)
  end

  def map_path
    Rails.application.routes.url_helpers.map_country_path(self)
  end

  def map_url
    Rails.application.routes.url_helpers.map_country_url(self)
  end

end
