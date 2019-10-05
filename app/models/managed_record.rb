class ManagedRecord < ActiveRecord::Base

  belongs_to :record, polymorphic: true
  belongs_to :manager
  
end
