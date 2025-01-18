
json.id @area.id
json.path area_path(@area)
json.url area_url(@area, host: @area.canonical_host)

json.label @area.label
json.subtitle @area.subtitle
json.parentPath polymorphic_path([@area.parent, nil])
json.events @area.events.publicly_visible, partial: 'api/events/event', as: :event

json.latitude @area.latitude
json.longitude @area.longitude
json.radius @area.radius
