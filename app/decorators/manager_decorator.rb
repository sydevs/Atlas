module ManagerDecorator

  def label
    name
  end

  def language_name
    LocalizationHelper.language_name(language_code)
  end

end
