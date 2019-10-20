require 'json'

module ApplicationHelper

  # TODO: Move all these JSON helpers into decorators

  def venue_json venue
    {
      id: venue.id,
      name: venue.label,
      latitude: venue.latitude,
      longitude: venue.longitude,
      full_address: venue.full_address,
      address: venue.address,
      events: venue.events.collect { |event|
        {
          id: event.id,
          name: event.label,
          description: event.description || event.category_description,
          room: event.room,
          category: event.category_name,
          raw_category: event.category,
          next_date: event.next_date,
          timing: event.timing_in_words,
        }
      },
    }
  end

  def event_json event
    {
      id: event.id,
      name: event.label,
      description: event.description,
      category: event.category_name,
      raw_category: event.category,
      upcoming_dates: upcoming_dates(event),
      timing: event.timing_in_words,
      venue: {
        id: event.venue.id,
        name: event.venue.name,
        address: event.venue.address,
        latitude: event.venue.latitude,
        longitude: event.venue.longitude,
      },
    }
  end

  def upcoming_dates event, limit = 10
    dates = []
    daily = (event.recurrence == 'day')
    interval = (daily ? 1 : 7)

    if event.start_date == event.end_date || (event.end_date.nil? and daily)
      dates << event.start_date
    elsif daily
      dates << [event.start_date, Date.today].min
    else
      date = Date.parse(event.recurrence)
      date += 7 if date > Date.today
      dates << date
    end

    while dates.length < limit
      next_date = dates[-1] + interval
      break if event.end_date.present? and next_date > event.end_date
      dates << next_date
    end

    dates.map(&:to_s)
  end

  def venues_json venues = nil
    (venues || @venues).collect { |venue| [venue.id, venue_json(venue)] }.to_h
  end

  def events_json events = nil
    (events || @events).collect { |event| [event.id, event_json(event)] }.to_h
  end

  def pretty_json json
    JSON.pretty_generate(json)
  end

end
