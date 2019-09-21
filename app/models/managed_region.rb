class ManagedRegion < ApplicationRecord

  belongs_to :region, polymorphic: true
  belongs_to :manager
  
end
