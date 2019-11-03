class Picture < ApplicationRecord

  # Extensions
  include ImageUploader::Attachment(:file) # adds an `file` virtual attribute

end
