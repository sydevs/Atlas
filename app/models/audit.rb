class Audit < Audited::Audit

  # Extensions
  include Searchable
  
  searchable_columns %w[auditable_type action audited_changes]

  # Scopes
  default_scope { includes(:user, :auditable).order(created_at: :desc) }

end
