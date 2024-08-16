class ManagedRecord < ApplicationRecord

  # Extensions
  searchable_columns %w[managers.name managers.email]

  # Associations
  belongs_to :record, polymorphic: true
  belongs_to :manager

  # Scopes
  default_scope { order(record_type: :asc) }
  scope :created_since, ->(since) { where('created_at >= ?', since) }

  # Callbacks
  after_destroy :unsubscribe_from_brevo!
  after_create :subscribe_to_brevo!
  after_create :new_managed_record_notification!

  # Methods

  def managed_by? user
    assigned_by_id == user.id
  end

  private

    def new_managed_record_notification!
      ManagedRecordMailer.with(managed_record: self).created.deliver_later
    end

    def subscribe_to_brevo!
      manager.update_brevo! update_management: true
    end

    def unsubscribe_from_brevo!
      manager.update_brevo! update_management: true
    end

end
