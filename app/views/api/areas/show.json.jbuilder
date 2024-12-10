
json.id @area.id
json.label @area.label
json.parentId @area.region_id
json.parentType 'Region'
json.events @area.events, partial: 'api/events/event', as: :event
