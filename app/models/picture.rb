class Picture < ApplicationRecord

  # Extensions
  include ImageUploader::Attachment(:file) # adds an `file` virtual attribute

  # Methods

  def managed_by? manager, super_manager: false # rubocop:disable Link/UnusedMethodArgument
    parent.managed_by?(manager)
  end

end
