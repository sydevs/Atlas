
json.id @region.id
json.label @region.label
json.countryCode @region.country_code
json.parentId @region.country_code
json.parentType 'country'
json.eventCount @region.events.publicly_visible.count

# TODO: Change all source data to use the Mapbox coordinate system
bounds = @region.bounds.map { |b| b.to_f.round(5) }
json.bounds [bounds[2], bounds[0], bounds[3], bounds[1]]

json.areas do
  json.array! @region.areas do |area|
    json.id area.id
    json.label area.short_label
    json.eventCount area.events.publicly_visible.count
  end
end
