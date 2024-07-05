module EventDecorator

  def decorated_location
    @location ||= (online? ? decorated_area : decorated_venue)
  end

  def decorated_area
    @area ||= begin
      area.extend(AreaDecorator)
    end
  end

  def decorated_venue
    @venue ||= begin
      venue.extend(VenueDecorator)
    end
  end

  def label
    if custom_name.present? && language_code == I18n.locale
      custom_name
    elsif inactive_category?
      I18n.translate('api.event.inactive_label', category: category_label, area: decorated_area.label)
    elsif online?
      I18n.translate('api.event.online_label', category: category_label, area: decorated_area.label)
    else
      I18n.translate('api.event.label', category: category_label, venue: decorated_venue.label)
    end
  end

  def address
    [room, decorated_location.address].compact.join(', ')
  end

  def category_name
    category ? I18n.translate(category, scope: 'activerecord.attributes.event.categories') : nil
  end

  def category_label
    category ? I18n.translate(category, scope: 'activerecord.attributes.event.category_labels') : nil
  end

  def category_description
    category ? I18n.translate(category, scope: 'activerecord.attributes.event.category_descriptions') : nil
  end

  def recurrence_in_words
    return nil if inactive_category?

    if start_date == end_date || (end_date.nil? && recurrence == 'day')
      start_date.year == Date.today.year ? start_date.to_s(:short) : start_date.to_s(:long)
    elsif recurrence == 'day'
      "#{start_date.to_s(:short)} - #{end_date.to_s(:short)}"
    else
      I18n.translate(recurrence, scope: 'activerecord.attributes.event.recurrences')
    end
  end

  def formatted_start_end_date
    end_date ? "#{start_date} - #{end_date}" : start_date
  end

  def formatted_start_end_time
    end_time ? "#{start_time} - #{end_time}" : start_time
  end

  def timing_in_words
    "#{recurrence_in_words}, #{formatted_start_end_time}"
  end

  def language_name
    LocalizationHelper.language_name(language_code)
  end

  def map_path
    Rails.application.routes.url_helpers.map_event_path(self)
  end

  def map_url
    Rails.application.routes.url_helpers.map_event_url(self, host: canonical_host)
  end

end
