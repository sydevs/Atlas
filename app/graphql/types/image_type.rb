module Types
  class ImageType < Types::BaseObject
    field :url, String, null: false
    field :thumbnail_url, String, null: false
  end
end
