module ManagerDecorator

  def label
    name
  end

  def language_name
    return nil unless language_code.present?

    I18nData.languages(I18n.locale)[language_code]&.split(/[,;]/)&.first
  end

end
