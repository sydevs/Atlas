module CountryDecorator

  def label
    CountryDecorator.get_label(country_code)
  end

  def short_label
    country_code
  end

  def self.get_label country_code
    ISO3166::Country[country_code].name
  end

end
