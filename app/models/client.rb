class Client < ApplicationRecord

  # Extensions
  include Searchable
  include Managed

  searchable_columns %w[label domain]
  audited except: %i[
    summary_email_sent_at
  ]

  # Validations
  validates_presence_of :label, :domain, :public_key, :secret_key

  # Scopes
  default_scope { order(last_accessed_at: :desc, updated_at: :desc) }
  scope :enabled, -> { where(enabled: true) }
  scope :disabled, -> { where(enabled: false) }

  # Callbacks
  before_validation :find_manager
  after_save :find_or_create_manager

  # Methods

  def map_config
    result = {}
    result[:bounds] = begin
      bounds = config['bounds'].split(',')
      [[bounds[0], bounds[1]], [bounds[2], bounds[3]]]
    end if config['bounds'].present?

    result
  end

end
