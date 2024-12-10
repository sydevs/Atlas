json.id @country.id
json.code @country.country_code
json.label @country.label
json.children do
  if @country.enable_custom_regions?
    json.array! @country.regions do |region|
      json.id region.id
      json.type 'region'
      json.name region.name
      json.eventCount region.events.publicly_visible.count
    end
  else
    json.array! @country.areas do |area|
      json.id area.id
      json.type 'area'
      json.name area.name
      json.eventCount area.events.publicly_visible.count
    end
  end
end
