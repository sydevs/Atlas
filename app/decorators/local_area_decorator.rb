module LocalAreaDecorator

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

end
