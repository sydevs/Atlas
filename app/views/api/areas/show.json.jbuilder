
json.id @area.id
json.path area_path(@area)
json.url area_url(@area, host: @area.canonical_host)

json.label @area.label
json.subtitle @area.subtitle
json.parentId @area.parent.id
json.parentType @area.parent.class.model_name.singular
json.events @area.events, partial: 'api/events/event', as: :event

json.latitude @area.latitude
json.longitude @area.longitude
json.radius @area.radius
