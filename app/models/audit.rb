class Audit < Audited::Audit

  # Extensions
  include Searchable
  
  searchable_columns %w[auditable_type action audited_changes]

  # Scopes
  default_scope { order(created_at: :desc) }
  scope :with_associations, -> { includes(:user, :auditable) }

end
