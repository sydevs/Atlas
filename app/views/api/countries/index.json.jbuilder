json.array! @countries do |country|
  json.id country.id
  json.code country.country_code
  json.label country.label
  json.eventCount country.events.publicly_visible.count
  json.defaultLanguageCode country.default_language_code
end
