module EventDecorator

  def label
    name || category_name
  end

  def language_names
    data = I18nData.languages(I18n.locale)
    languages.map { |l| data[l] }
  end

  def address
    { room: room }.merge(venue.address)
  end

  def category_name
    I18n.translate(category, scope: %i[category title])
  end

  def category_description
    I18n.translate(category, scope: %i[category description])
  end

  def timing
    result = ''

    if start_date == end_date || (end_date.nil? and recurrence == 'day')
      result += start_date.to_s(:short)
    elsif recurrence == 'day'
      result += "#{start_date.to_s(:short)} - #{end_date.to_s(:short)}"
    else
      result += "Every #{recurrence.humanize.titleize}"
    end

    result += ", #{start_time}"
    result += " - #{end_time}" if end_time
    result
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

  private

    def date_of_next day
      date = Date.parse(day)
      delta = date > Date.today ? 0 : 7
      date + delta
    end

end
