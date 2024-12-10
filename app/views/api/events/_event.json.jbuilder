json.id event.id
json.label event.label
json.address event.address
json.online event.online?

json.locationId event.location.id
json.locationType event.location.class.model_name
json.latitude event.latitude
json.longitude event.longitude
json.distance event.venue.distance_in_words(@location) if @location.present? && event.venue.present?

json.timeZone event.time_zone
json.timing event.recurrence_in_words(%i[timing], short: true)
json.recurrence event.recurrence_in_words(%i[recurrence], short: true)