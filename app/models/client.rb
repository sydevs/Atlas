class Client < ApplicationRecord

  # Extensions
  include Searchable
  include Managed

  searchable_columns %w[label domain]
  audited except: %i[
    summary_email_sent_at
  ]

  enum type: { website: 0, app: 1, wix: 2, other: 100 }

  # Validations
  validates_presence_of :label, :public_key, :secret_key
  # validates_presence_of :domain, if: :requires_domain?

  # Scopes
  default_scope { order(last_accessed_at: :desc, updated_at: :desc) }
  scope :enabled, -> { where(enabled: true) }
  scope :disabled, -> { where(enabled: false) }

  # Methods

  def map_config
    result = {}
    result[:bounds] = begin
      bounds = config['bounds'].split(',')
      [[bounds[0], bounds[1]], [bounds[2], bounds[3]]]
    end if config['bounds'].present?

    result
  end

  private

    def requires_domain?
      website? || wix?
    end

end
