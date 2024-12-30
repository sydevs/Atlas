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

json.registration do
  json.mode @event.registration_mode
  json.externalUrl @event.registration_url if @event.registration_mode != 'native'
  json.maxParticipants @event.registration_limit
  json.participantCount @event.registrations.count
  json.questions do
    json.array! @event.registration_question do |question|
      json.slug question
      json.title translate_enum_value(Event, :registration_question, question)
    end
  end
end

json.images do
  json.array! @event.pictures do |picture|
    json.url picture.file.url
    json.thumbnailUrl picture.file.url(:thumbnail)
  end
end

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

json.contact do
  json.phoneNumber @event.contact_info['phone_number']
  json.phoneName @event.contact_info['phone_name']
  json.emailAddress @event.contact_info['email_address']
end

json.location do
  json.id @event.location.id
  json.type @event.location.class.model_name.singular
  json.address @event.location.address
  json.directionsUrl @event.location.try(:directions_url)
  json.latitude @event.location.latitude
  json.longitude @event.location.longitude
end