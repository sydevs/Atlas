
json.id @region.id
json.label @region.label
json.countryCode @region.country_code
json.parentId @region.country_code
json.parentType 'country'
json.areas do
  json.array! @region.areas do |area|
    json.id area.id
    json.label area.label
    json.eventCount area.events.publicly_visible.count
  end
end
