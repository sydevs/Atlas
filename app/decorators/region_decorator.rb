module RegionDecorator

  def label
    "#{short_label}, #{country_code}"
  end

  def short_label
    translations[I18n.locale.to_s] || name
  end

end
