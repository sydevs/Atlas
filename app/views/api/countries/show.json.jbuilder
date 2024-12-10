json.id @country.id
json.code @country.country_code
json.label @country.label
json.areas do
  json.array! @country.regions do |region|
    json.id region.id
    json.name region.name
    json.eventCount region.events.publicly_visible.count
  end
end
