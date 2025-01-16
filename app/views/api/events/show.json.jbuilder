json.id @event.id
json.path event_path(@event)
json.url event_url(@event, host: @event.canonical_host)
json.category @event.category

json.online @event.online?

json.updatedAt @event.updated_at.iso8601

json.label @event.label
json.description @event.description
json.descriptionHtml @event.description_html

json.category @event.category
json.languageCode @event.language_code

if @event.inactive_category? || !@event.next_recurrence_at.present?
  json.registration nil
else
  json.registration do
    json.mode @event.registration_mode
    json.externalUrl @event.registration_url unless @event.native_registration_mode?
    json.maxParticipants @event.registration_limit
    json.participantCount @event.registrations.count
    json.questions @event.registration_question
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
    json.recurrenceType @event.recurrence_type
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

json.location do
  json.countryCode @event.country_code
  json.areaPath area_path(@event.area_id)
  json.areaName @event.area.name # TODO: Provide translatable area names?

  if @event.online?
    json.platform "zoom"
    json.extract! @event.area, :latitude, :longitude
    json.venue nil
  else
    json.regionCode @event.venue.region_code # TODO: Change this so that region_code is available for online events
    json.venuePath venue_path(@event.venue_id)
    json.extract! @event.venue, :latitude, :longitude
    json.venue do
      venue = @event.venue
      json.extract! venue, :name, :street, :city
      json.directionsUrl venue.directions_url
      json.address [venue.street, venue.city, venue.region_code, venue.country_code].compact.join(', ')
    end
  end
end
