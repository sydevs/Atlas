json.status 'success'
json.results do
  json.partial! "api/records/#{@model.model_name.singular_route_key}", @model.model_name.singular_route_key.to_sym => @record, verbose: true
end
