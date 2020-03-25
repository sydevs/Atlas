class GeojsonUploader < CarrierWave::Uploader::Base

  FILENAME = 'meditation-venues.geojson'

  # Override the directory where uploaded files will be stored.
  # This is a sensible default for uploaders that are meant to be mounted:
  def store_dir
    'geojson'
  end

  def cache_dir
    "#{Rails.root}/tmp/uploads"
  end

  # Replace all file names with a unique random string
  def filename
    FILENAME
  end

end
