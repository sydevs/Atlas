json.array! @countries do |country|
  json.id country.id
  json.label country.label
  json.eventCount country.events.publicly_visible.count
end
