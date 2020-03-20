module ProvinceDecorator

  def name
    ProvinceDecorator.get_name(province_code, country_code)
  end

  def label
    "#{name}, #{country_code}"
  end

  def short_label
    name
  end

  def self.get_name province_code, country_code
    return nil unless province_code.present? && country_code.present?
    
    ISO3166::Country[country_code].subdivisions[province_code]['name'].split(',')[0]
  end

  def self.get_label province_code, country_code
    return nil unless province_code.present? && country_code.present?
    
    "#{ProvinceDecorator.get_name(province_code, country_code)}, #{country_code}"
  end

end
