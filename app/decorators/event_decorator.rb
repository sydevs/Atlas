module EventDecorator

  def label fallback_only: false
    if name.present? && !fallback_only
      name
    elsif category && venue&.name
      category_label = translate_enum_value(self, :category_label, category)
      venue_label = venue.extend(VenueDecorator).label
      I18n.translate('map.listing.event_name', category: category_label, venue: venue_label)
    else
      category_name
    end
  end

  def language_name
    I18nData.languages(I18n.locale)[language]
  end

  def address
    { room: room }.merge(venue.address)
  end

  def address_text
    @address_text ||= [room, venue.street, venue.city, venue.province_name, venue.country_code].compact.join(', ')
  end

  def category_name
    translate_enum_value(self, :category)
  end

  def category_description
    translate_enum_value(self, :category_description, category)
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
    [start_date, end_date].compact.join(' - ')
  end

  def formatted_start_end_time
    [start_time, end_time].compact.join(' - ')
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
      date += 7 if date > Date.today
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
    I18nData.languages(I18n.locale)[language].split(/[,;]/)[0]
  end

  def to_h
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
        upcoming: upcoming_dates.map(&:to_s)
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
    }
  end

  private

    def date_of_next day
      date = Date.parse(day)
      delta = date > Date.today ? 0 : 7
      date + delta
    end

end
