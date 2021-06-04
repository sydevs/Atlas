module CountryDecorator

  def label
    CountryDecorator.get_label(country_code)
  end

  def short_label
    CountryDecorator.get_short_label(country_code)
  end

  def bounds
    CountryDecorator.get_bounds(country_code)
  end

  def self.get_label country_code
    ISO3166::Country.translations[country_code]
  end

  def self.get_short_label country_code
    I18n.translate(country_code.downcase, scope: 'cms.country_codes', default: country_code)
  end

  def self.get_bounds country_code
    c = ISO3166::Country[country_code]
    [
      -c.min_longitude, c.min_latitude, # southwest
      c.max_longitude, c.max_latitude # northeast
    ]
  end

end
