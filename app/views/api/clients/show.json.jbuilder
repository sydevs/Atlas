
json.name @client.label
json.domain @client.domain
json.initialPath @client.location ? polymorphic_path([@client.location]) : nil
json.locale @client.locale
