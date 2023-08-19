module LocalizationHelper

  I18N_KEYS = {
    OfflineEvent => :offline_event,
    OnlineEvent => :online_event,
  }

  def translate_model model, pluralization = :singular, locale: nil
    key = pluralization == :plural ? 'plural' : 'single'
    i18n_key = I18N_KEYS[model] || model.model_name.i18n_key
    result = translate(key, scope: [:activerecord, :models, i18n_key], locale: locale)

    if i18n_key == :region && @context.try(:country_code)
      translate(key, scope: [:cms, :region_types, @context.country_code.downcase], locale: locale, default: result)
    else
      result
    end
  end

  def translate_model_count model, count = nil
    if model.is_a?(ActiveRecord::Relation)
      count = model.count
      model = model.klass
    end

    i18n_key = I18N_KEYS[model] || model.model_name.i18n_key
    result = translate(i18n_key, scope: %i[activerecord models], count: count, locale: I18n.locale)

    if i18n_key == :region && @context.try(:country_code)
      result = translate(i18n_key, scope: [:cms, :region_types, @context.country_code.downcase], locale: locale, default: result)
    end

    "#{number_with_delimiter(count)} #{result}"
  end

  def translate_enum_value model, attr, value = nil
    value ||= model.send(attr)
    i18n_key = I18N_KEYS[model] || model.model_name.i18n_key
    I18n.translate value, scope: [:activerecord, :attributes, i18n_key, attr.to_s.pluralize], locale: I18n.locale
  end

  def translate_attribute model, attr
    i18n_key = I18N_KEYS[model] || model.model_name.i18n_key
    I18n.translate attr, scope: [:activerecord, :attributes, i18n_key], locale: I18n.locale
  end

  def self.language_name language_code, locale: :en
    return nil unless language_code.present?

    I18nData.languages(locale)[language_code]&.split(/[,;]/)&.first
  end

end
