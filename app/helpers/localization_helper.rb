module LocalizationHelper

  I18N_KEYS = {
    OfflineEvent => 'offline_event',
    OnlineEvent => 'online_event',
  }

  def translate_model model, pluralization = :singular
    key = pluralization == :plural ? 'plural' : 'single'
    i18n_key = I18N_KEYS[model] || model.model_name.i18n_key
    translate(key, scope: [:activerecord, :models, i18n_key])
  end

  def translate_model_count model, count = nil
    if model.is_a?(ActiveRecord::Relation)
      count = model.count
      model = model.klass
    end

    i18n_key = I18N_KEYS[model] || model.model_name.i18n_key
    "#{number_with_delimiter(count)} #{translate(i18n_key, scope: %i[activerecord models], count: count)}"
  end

  def translate_enum_value model, attr, value = nil
    value ||= model.send(attr)
    i18n_key = I18N_KEYS[model] || model.model_name.i18n_key
    I18n.translate value, scope: [:activerecord, :attributes, i18n_key, attr.to_s.pluralize]
  end

  def translate_attribute model, attr
    i18n_key = I18N_KEYS[model] || model.model_name.i18n_key
    I18n.translate attr, scope: [:activerecord, :attributes, i18n_key]
  end

end
