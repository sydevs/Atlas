json.success true
json.results do
  json.array! @regions do |region|
    json.name region.short_label
    json.value region.province_code
  end
end