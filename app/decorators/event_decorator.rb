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

  def recurrence_in_words parts=%i[recurrence timing dates], short: false
    return nil if inactive_category?

    parts.map! do |key|
      case key
      when :recurrence
        wday = I18n.translate(recurrence.starts_at.wday, scope: %i[map weekdays])
        I18n.translate recurrence_type, scope: "activerecord.attributes.recurrable.descriptions", locale: I18n.locale, weekday: wday
      when :timing
        if short
          recurrence.starts_at.to_s(:time)
        else
          timing = [
            recurrence.starts_at.to_s(:time),
            recurrence.ends_at&.to_s(:time)
          ]

          if timing[1] == nil || timing[0] == timing[1]
            timing[0]
          else
            timing.join(" - ")
          end
        end
      when :dates
        month = short ? '%b' : '%B'
        base_format = "%-d #{month}"
        base_format += ' %Y' unless short && recurrence.starts_at.year == Time.now.year
        return recurrence.starts_at.strftime(base_format) if recurrence.infinite? || recurrence.starts_at.strftime(base_format) == recurrence.ends_at.strftime(base_format)

        start_format = '%-d'
        start_format += " #{month}" unless recurrence.starts_at.month == recurrence.ends_at.month
        start_format += ' %Y' unless recurrence.starts_at.year == recurrence.ends_at.year
        base_format += ' %Y' if recurrence.starts_at.year == Time.now.year && recurrence.starts_at.year != recurrence.ends_at.year

        [
          recurrence.starts_at.strftime(start_format),
          recurrence.ends_at.strftime(base_format)
        ].join(" - ")
      end
    end

    parts.reject(&:nil?).join(", ")
  end

  def language_name
    LocalizationHelper.language_name(language_code) || translate('cms.hints.unspecified')
  end

  def map_path
    Rails.application.routes.url_helpers.map_event_path(self)
  end

  def map_url
    Rails.application.routes.url_helpers.map_event_url(self, host: canonical_host)
  end

end
