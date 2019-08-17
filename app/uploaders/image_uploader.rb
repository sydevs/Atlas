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

  def filename
    "#{secure_token}.#{file.extension}" if original_filename.present?
  end

  protected

    def secure_token
      media_original_filenames_var = :"@#{mounted_as}_original_filenames"

      unless model.instance_variable_get(media_original_filenames_var)
        model.instance_variable_set(media_original_filenames_var, {})
      end

      unless model.instance_variable_get(media_original_filenames_var).map{|k,v| k }.include? original_filename.to_sym
        new_value = model.instance_variable_get(media_original_filenames_var).merge({"#{original_filename}": SecureRandom.uuid})
        model.instance_variable_set(media_original_filenames_var, new_value)
      end

      model.instance_variable_get(media_original_filenames_var)[original_filename.to_sym]
    end
end
