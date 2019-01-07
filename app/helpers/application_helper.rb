require 'json'

module ApplicationHelper

  def venue_json venue
    {
      id: venue.id,
      name: venue.label,
      latitude: venue.latitude,
      longitude: venue.longitude,
      full_address: venue.address(:full),
      address: venue.address,
      events: venue.events.collect { |event|
        {
          id: event.id,
          name: event.label,
          description: event.description || event.category_description,
          room: event.room || venue.address_room,
          category: event.category_name,
          raw_category: event.category,
          next_date: event.next_date,
          timing: event.timing,
        }
      }
    }
  end

  def event_json event
    {
      id: event.id,
      name: event.label,
      category: event.category_name,
      raw_category: event.category,
      next_date: event.next_date,
      timing: event.timing,
      venue: event.venue.name,
      address: event.venue.address,
      latitude: event.venue.latitude,
      longitude: event.venue.longitude,
    }
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
