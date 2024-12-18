json.id @country.id
json.code @country.country_code
json.label @country.label
json.eventCount @country.events.publicly_visible.count

# TODO: Change all source data to use the Mapbox coordinate system
bounds = @country.bounds.map { |b| b.to_f.round(5) }
json.bounds [bounds[2], bounds[0], bounds[3], bounds[1]]

json.children do
  if @country.enable_regions?
    json.array! @country.regions do |region|
      json.id region.id
      json.type 'region'
      json.label region.short_label
      json.eventCount region.events.publicly_visible.count
    end
  else
    json.array! @country.areas do |area|
      json.id area.id
      json.type 'area'
      json.label area.short_label
      json.eventCount area.events.publicly_visible.count
    end
  end
end
