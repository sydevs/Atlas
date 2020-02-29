json.success true
json.results do
  json.array! @countries do |country|
    json.name country.label
    json.value country.country_code
  end
end