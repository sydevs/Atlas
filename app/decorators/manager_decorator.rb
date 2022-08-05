module ManagerDecorator

  def label
    name
  end

  def language_name
    I18nData.languages(I18n.locale)[language_code]&.split(/[,;]/)&[0]
  end

end
