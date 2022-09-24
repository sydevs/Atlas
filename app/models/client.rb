class Client < ApplicationRecord

  # Extensions
  include Searchable
  include Managed

  searchable_columns %w[label domain]
  audited except: %i[
    summary_email_sent_at
  ]

  enum embed_type: %i[iframe script url], _suffix: 'embed'
  enum routing_type: %i[query path], _suffix: 'routing'
  enum default_view: %i[map list], _suffix: 'view'

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

  def domain
    domain = config&.dig('domain')
    domain if domain.present?
  end

  def locale
    locale = config&.dig('locale')
    locale.present? ? locale : 'en'
  end

  def url
    "https://#{domain || "wemeditate.com#{"/" + locale if locale != 'en'}"}/map"
  end

  private

    def validate_config
      self.location_id = nil unless location_type.present?

      errors.add(:location_id, :invalid) if location_id.present? && location.nil?
      # errors.add(:domain, :blank) unless config['domain'].present?
      errors.add(:domain, :invalid) unless !config['domain'].present? || config['domain'].match(/^[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(:[0-9]{1,5})?$/)
    end

end
