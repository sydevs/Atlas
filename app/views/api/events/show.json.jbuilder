json.id @event.id
json.path event_path(@event)
json.url event_url(@event, host: @event.canonical_host)

json.online @event.online?
json.updatedAt @event.updated_at.iso8601

json.label @event.label
json.description @event.description
json.descriptionHtml @event.description_html

json.category @event.category
json.languageCode @event.language_code

if @event.inactive_category? && @event.next_recurrence_at.present?
  json.registration nil
else
  json.registration do
    json.mode @event.registration_mode
    json.externalUrl @event.registration_url unless @event.native_registration_mode?
    json.maxParticipants @event.registration_limit
    json.participantCount @event.registrations.count
    json.questions do
      json.array! @event.registration_question do |question|
        json.slug question
        json.title translate_enum_value(Event, :registration_question, question)
      end
    end
  end
end

json.images do
  json.array! @event.pictures do |picture|
    json.url picture.file.url
    json.thumbnailUrl picture.file.url(:thumbnail)
  end
end

if @event.inactive_category?
  json.timing nil
else
  json.timing do
    json.type @event.recurrence_type
    json.localStartTime @event.recurrence_data[:start_time]
    json.localEndTime @event.recurrence_data[:end_time]
    json.duration @event.duration
    json.timeZone @event.time_zone

    json.firstDate @event.first_recurrence_at&.iso8601
    json.lastDate @event.last_recurrence_at&.iso8601
    json.upcomingDates @event.upcoming_recurrences(limit: 7).map(&:iso8601)
    json.recurrenceCount @event.recurrence&.finite? ? @event.recurrence.events.to_a.count : nil
  end
end

if @event.contact_info.present? && @event.contact_info['phone_number'].present?
  json.contact do
    json.phoneNumber @event.contact_info['phone_number']
    json.phoneName @event.contact_info['phone_name']
  end
else
  json.contact nil
end

if @event.online?
  json.location do
    area = @event.area.extend(AreaDecorator)
    json.id area.id
    json.type 'area'
    # TODO: Fix these hard coded strings
    json.label "Online Class" # via Zoom"
    json.subtitle "Hosted from #{area.label}"
    json.platform "zoom"
    json.latitude area.latitude
    json.longitude area.longitude
  end
else
  json.location do
    venue = @event.venue.extend(VenueDecorator)
    json.id venue.id
    json.type 'venue'
    json.directionsUrl venue.directions_url
    json.latitude venue.latitude
    json.longitude venue.longitude

    if venue.name
      json.label venue.name
      json.subtitle venue.address
    else
      json.label venue.street
      json.subtitle [venue.city, venue.region_code, venue.country_code].compact.join(', ')
    end
  end
end