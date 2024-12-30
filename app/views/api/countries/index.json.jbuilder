json.array! @countries do |country|
  json.id country.id
  json.path country_path(country.country_code)
  json.url country_url(country.country_code, host: country.canonical_host)
  json.code country.country_code

  json.label country.label
  json.eventCount country.events.publicly_visible.count
  json.defaultLanguageCode country.default_language_code
end
