module ProvinceDecorator

  def name
    ISO3166::Country[country_code].subdivisions[province_code]['name']
  end

  def label
    "#{name}, #{country_code}"
  end

  def short_label
    name
  end

  def self.get_name province_code, country_code
    ISO3166::Country[country_code].subdivisions[province_code]['name'].split(',')[0]
  end

  def self.get_label province_code, country_code
    "#{ISO3166::Country[country_code].subdivisions[province_code]['name']}, #{country_code}"
  end

end
