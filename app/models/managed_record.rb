class ManagedRecord < ApplicationRecord

  # Extensions
  searchable_columns %w[managers.name managers.email]

  # Associations
  belongs_to :record, polymorphic: true
  belongs_to :manager

  # Scopes
  scope :created_since, ->(since) { where('created_at >= ?', since) }

  # Callbacks
  after_create :subscribe_to_sendinblue!
  after_destroy :unsubscribe_from_sendinblue!

  # Methods

  def managed_by? user
    assigned_by_id == user.id
  end

  private

    def subscribe_to_sendinblue!
      manager.update_sendinblue! update_management: true
    end

    def unsubscribe_from_sendinblue!
      manager.update_sendinblue! update_management: true
    end

end
