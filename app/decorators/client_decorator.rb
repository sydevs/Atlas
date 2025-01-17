module ClientDecorator

  def embed_url
    map_root_url(key: public_key)
  end
  
end
