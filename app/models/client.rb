class Client < ApplicationRecord

  # Extensions
  include Searchable
  include Managed

  searchable_columns %w[label domain]
  audited except: %i[
    summary_email_sent_at
  ]

  enum embed_type: %i[iframe script url]
  enum routing_type: %i[query path]
  # enum location_type: %i[world country region area]

  # Associations
  belongs_to :location, polymorphic: true, optional: true

  # Validations
  validates_presence_of :label, :public_key, :secret_key
  validate :validate_config

  # Scopes
  default_scope { order(last_accessed_at: :desc, updated_at: :desc) }
  scope :enabled, -> { where(enabled: true) }
  scope :disabled, -> { where(enabled: false) }

  # Methods

  def parent
    location || nil
  end

  def validate_config
    self.location_id = nil unless location_type.present?

    errors.add(:location_id, :invalid) if location_id.present? && location.nil?
    # errors.add(:domain, :blank) unless config['domain'].present?
    errors.add(:domain, :invalid) unless !config['domain'].present? || config['domain'].match(/^[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(:[0-9]{1,5})?$/)
  end

  def map_config
    result = {}
    result[:bounds] = begin
      bounds = config['bounds'].split(',')
      [[bounds[0], bounds[1]], [bounds[2], bounds[3]]]
    end if config['bounds'].present?

    result
  end

end
