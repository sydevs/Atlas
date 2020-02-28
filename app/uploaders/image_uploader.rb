class ImageUploader < CarrierWave::Uploader::Base

  include CarrierWave::MiniMagick
  process convert: :jpg

  version :thumbnail do
    process resize_to_limit: [320, nil]
  end

  # Add a white list of extensions which are allowed to be uploaded.
  # For images you might use something like this:
  def extension_whitelist
    %w[png jpg jpeg]
  end

  # Override the directory where uploaded files will be stored.
  # This is a sensible default for uploaders that are meant to be mounted:
  def store_dir
    "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end

  def cache_dir
    "#{Rails.root}/tmp/uploads"
  end

  # Replace all file names with a unique random string
  def filename
    "#{secure_token(10)}.#{file.extension}" if original_filename.present?
  end

  protected

    # This checks if a secure token already exists for this file, and otherwise generates a new one.
    def secure_token(length = 16)
      var = :"@#{mounted_as}_secure_token"
      model.instance_variable_get(var) || model.instance_variable_set(var, SecureRandom.hex(length / 2))
    end

end
