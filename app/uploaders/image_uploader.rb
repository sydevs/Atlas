require 'image_processing/mini_magick'

class ImageUploader < Shrine

  # plugins and uploading logic
  plugin :validation_helpers
  plugin :determine_mime_type
  plugin :derivatives

  Attacher.validate do
    validate_max_size 5 * 1024 * 1024
    validate_mime_type %w[image/jpeg image/png image/webp]
  end

  Attacher.derivatives_storage do |original|
    magick = ImageProcessing::MiniMagick.source(original)
    { thumbnail: magick.resize_to_limit!(300, 300) }
  end

end
