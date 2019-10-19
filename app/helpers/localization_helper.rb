
module LocalizationHelper

  def translate_model model, pluralization = :singular
    key = pluralization == :plural ? 'plural' : 'single'
    translate(key, scope: [:activerecord, :models, model.model_name.i18n_key])
  end

  def translate_model_count model, count = nil
    if model.is_a?(ActiveRecord::Relation)
      count = model.count
      model = model.klass
    end
    
    "#{number_with_delimiter(count)} #{translate(model.model_name.i18n_key, scope: %i[activerecord models], count: count)}"
  end

  def translate_enum_value model, attr, value = nil
    value ||= model.send(attr)
    I18n.translate value, scope: [:activerecord, :attributes, model.model_name.i18n_key, attr.to_s.pluralize]
  end

  def translate_attribute model, attr
    I18n.translate attr, scope: [:activerecord, :attributes, model.model_name.i18n_key]
  end

end