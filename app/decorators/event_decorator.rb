module EventDecorator

  def decorated_venue
    @venue ||= venue&.extend(VenueDecorator)
  end

  def label fallback_only: false
    if name.present? && !fallback_only
      name
    elsif category && venue&.name
      if online?
        I18n.translate('map.listing.online_event_name', category: category_label, venue: venue.city)
      else
        I18n.translate('map.listing.event_name', category: category_label, venue: decorated_venue.label)
      end
    else
      category_name
    end
  end

  def address
    { room: room }.merge(decorated_venue.address)
  end

  def address_text
    @address_text ||= begin
      fields = online ? [venue.city, decorated_venue.province_name] : [room, venue.street, venue.city, decorated_venue.province_name]
      fields << CountryDecorator.get_short_label(venue.country_code)
      fields.compact.join(', ')
    end
  end

  def category_name
    category ? translate_enum_value(self, :category) : nil
  end

  def category_label
    category ? I18n.translate(category, scope: 'activerecord.attributes.event.category_labels') : nil
  end

  def category_description
    category ? I18n.translate(category, scope: 'activerecord.attributes.event.category_descriptions') : nil
  end

  def recurrence_in_words
    result = ''

    if start_date == end_date || (end_date.nil? and recurrence == 'day')
      result += start_date.to_s(:short)
    elsif recurrence == 'day'
      result += "#{start_date.to_s(:short)} - #{end_date.to_s(:short)}"
    else
      result += translate_enum_value(self, :recurrence)
    end

    result
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

  def upcoming_dates limit = 10
    dates = []
    daily = (recurrence == 'day')
    interval = (daily ? 1 : 7)

    if start_date == end_date || (end_date.nil? && daily)
      dates << start_date
    elsif daily
      dates << [start_date, Date.today].min
    else
      date = Date.parse(recurrence)
      date += 7 if date < Date.today
      dates << date
    end

    while dates.length < limit
      next_date = dates[-1] + interval
      break if end_date.present? && next_date > end_date

      dates << next_date
    end

    dates
  end

  def escalates_in_days_in_words
    distance_of_time_in_words(Time.now, needs_escalation_at)
  end

  def expires_in_days_in_words
    distance_of_time_in_words(Time.now, expires_at)
  end
  
  def language_name
    I18nData.languages(I18n.locale)[language_code].split(/[,;]/)[0]
  end

  def as_json(_context = nil)
    {
      id: id,
      label: label,
      path: Rails.application.routes.url_helpers.map_event_path(self),
      description: description,
      address: address_text,
      category: category,
      timing: {
        recurrence: recurrence,
        start_date: start_date.to_s,
        end_date: end_date&.to_s,
        time: formatted_start_end_time,
        registration_end_time: end_date ? Time.parse("#{end_date} #{end_time || start_time}") : nil,
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

  private

    def date_of_next day
      date = Date.parse(day)
      delta = date > Date.today ? 0 : 7
      date + delta
    end

end
