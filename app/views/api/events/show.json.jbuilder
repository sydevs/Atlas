json.id @event.id
json.path @event.map_path
json.url @event.map_url

json.online @event.online?
json.updatedAt @event.updated_at.iso8601

json.label @event.label
json.description @event.description
json.descriptionHtml @event.description_html

json.category @event.category_name
json.language @event.language_name
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
  json.firstDate @event.first_recurrence_at
  json.lastDate @event.last_recurrence_at
  json.upcomingDates @event.upcoming_recurrences(limit: 7)
  json.recurrenceCount @event.recurrence&.finite? ? @event.recurrence.events.to_a.count : nil

  json.startTime @event.recurrence&.starts_at&.to_s(:time)
  json.endTime @event.recurrence&.ends_at&.to_s(:time)

  json.recurrence @event.recurrence_type
  json.duration @event.duration
  json.timeZone @event.time_zone
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