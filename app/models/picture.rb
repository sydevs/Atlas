class Picture < ApplicationRecord

  # Extensions
  mount_uploader :file, ImageUploader

  # Associations
  belongs_to :parent, polymorphic: true

  # Methods

  def managed_by? manager, super_manager: nil # rubocop:disable Link/UnusedMethodArgument
    parent.managed_by?(manager)
  end

end
