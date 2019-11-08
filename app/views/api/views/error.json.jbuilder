json.status 'error'
json.code response.status
json.message Rack::Utils::HTTP_STATUS_CODES[response.status]
