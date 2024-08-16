module ClientDecorator

  def embed_url
    if location_type.present? && config.dig("default_view") == "list"
      polymorphic_url([:map, location_type.downcase.to_sym], "#{location_type.downcase}_id": location_id, key: public_key)
    else
      map_root_url(key: public_key)
    end
  end
  
end
