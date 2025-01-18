
json.name @client.label
json.initialPath @client.location ? polymorphic_path([@client.location]) : nil
json.locale @client.locale
