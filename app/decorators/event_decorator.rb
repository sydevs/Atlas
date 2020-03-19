module EventDecorator

  def label fallback_only: false
    if name.present? && !fallback_only
      name
    elsif category && venue&.name
      category_label = I18n.translate(category, scope: %i[map categories label])
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
    category ? I18n.translate(category, scope: %i[map categories title]) : ''
  end

  def category_description
    category ? I18n.translate(category, scope: %i[map categories description]) : ''
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

  def timing_description
    if category == 'course'
      if start_date && end_date
        weeks = start_date.step(end_date, 7).count
        duration = I18n.translate('map.categories.timing.weeks', count: weeks)
        I18n.translate('map.categories.timing.course', duration: duration)
      else
        I18n.translate('map.categories.timing.course_fallback')
      end
    elsif recurrence == 'day'
      ''
    else
      I18n.translate('map.categories.timing.ongoing')
    end
  end

  def timing_in_words
    "#{recurrence_in_words}, #{formatted_start_end_time}"
  end

  def next_date
    date = nil

    if start_date == end_date || (end_date.nil? and recurrence == 'day')
      date = start_date
    elsif recurrence == 'day'
      date = [start_date, Date.today].min
    else
      date = date_of_next(recurrence)
    end

    date.to_s
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

  def registration_label
    I18n.translate('map.registration.action', service: translate_enum_value(self, :registration_mode))
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
      timing: {
        dates: recurrence_in_words,
        times: formatted_start_end_time,
        upcoming: upcoming_dates.map(&:to_s)
      },
      language: {
        code: language,
        name: language_name,
      },
      images: pictures.map { |picture|
        {
          url: picture.file.url,
          thumbnail_url: picture.file.url(:thumbnail),
        }
      },
      registration: {
        mode: registration_mode,
        label: registration_label,
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
