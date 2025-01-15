json.id event.id
json.path event_path(event)
json.label event.label
json.category event.category

json.address event.location.address
json.online event.online?
json.languageCode event.language_code

json.locationId event.location.id
json.locationType event.location.class.model_name.singular
json.latitude event.latitude
json.longitude event.longitude
json.distance event.venue.distance(@location) if @location.present? && event.venue.present?

json.timeZone event.time_zone
json.firstDate event.first_recurrence_at&.iso8601
json.nextDate event.next_recurrence_at&.iso8601
json.duration event.duration

json.recurrenceType event.recurrence_type