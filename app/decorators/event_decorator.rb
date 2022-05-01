module EventDecorator

  def decorated_venue
    @venue ||= venue&.extend(VenueDecorator)
  end

  def label
    if custom_name.present?
      custom_name
    elsif category && venue&.name
      if online?
        I18n.translate('map.listing.online_event_name', category: category_label, city: venue.city)
      else
        I18n.translate('map.listing.event_name', category: category_label, venue: decorated_venue.label)
      end
    else
      category_name
    end
  end

  def address
    @address ||= begin
      fields = online ? [venue.city, decorated_venue.province_name] : [room, venue.street, venue.city, decorated_venue.province_name]
      fields << CountryDecorator.get_short_label(venue.country_code)
      fields.compact.join(', ')
    end
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
    I18nData.languages(I18n.locale)[language_code].split(/[,;]/)[0]
  end

  def map_path
    Rails.application.routes.url_helpers.map_event_path(self)
  end

  def map_url
    Rails.application.routes.url_helpers.map_event_url(self)
  end

  def as_json(_context = nil)
    {
      id: id,
      label: label,
      path: Rails.application.routes.url_helpers.map_event_path(self),
      description: description,
      address: address,
      category: category,
      timing: {
        recurrence: recurrence,
        start_date: start_date.to_s,
        end_date: end_date&.to_s,
        time: formatted_start_end_time,
        registration_end_time: registration_end_time,
      },
      language_code: language_code,
      images: pictures.map { |picture|
        {
          url: picture.file.url,
          thumbnail_url: picture.file.url(:thumbnail),
        }
      },
      registration: {
        mode: registration_mode,
        url: registration_url,
      },
      online: online,
      online_url: online_url,
    }
  end

end
