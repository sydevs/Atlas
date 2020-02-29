json.success true
json.results do
  json.array! @provinces do |province|
    json.name province.short_label
    json.value province.province_code
  end
end