class ManagedRecord < ApplicationRecord

  belongs_to :record, polymorphic: true
  belongs_to :manager
  
end
