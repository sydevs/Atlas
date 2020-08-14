module CountryDecorator

  def label
    CountryDecorator.get_label(country_code)
  end

  def short_label
    I18n.translate(country_code.downcase, scope: 'cms.country_codes', default: country_code)
  end

  def self.get_label country_code
    ISO3166::Country.translations[country_code]
  end

end
