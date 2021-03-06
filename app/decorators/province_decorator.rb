module ProvinceDecorator

  def name
    ProvinceDecorator.get_name(province_code, country_code)
  end

  def label
    ProvinceDecorator.get_label(province_code, country_code)
  end

  def short_label
    name
  end

  def self.get_name province_code, country_code
    return nil unless province_code.present? && country_code.present?
    
    ISO3166::Country[country_code].subdivisions.dig(province_code, 'translations', I18n.locale.to_s).split(',')[0]
  end

  def self.get_label province_code, country_code
    return nil unless province_code.present? && country_code.present?
    
    "#{ProvinceDecorator.get_name(province_code, country_code)}, #{CountryDecorator.get_short_label(country_code)}"
  end

end
