class Client < ApplicationRecord

  DEFAULT_COLORS = { primary_color: "#92bbb8", secondary_color: "#e08e79", tertiary_color: "#a1c3d7" }

  # Extensions
  include Searchable
  include Managed
  # include Audited

  nilify_blanks
  searchable_columns %w[label domain]

  store_accessor :config, :embed_type, :routing_type, :default_view, :domain, :locale, :primary_color, :secondary_color, :tertiary_color

  enum embed_type: %i[iframe script url], _suffix: 'embed'
  enum routing_type: %i[query path], _suffix: 'routing'
  enum default_view: %i[map list], _suffix: 'view'

  # Associations
  belongs_to :location, polymorphic: true, optional: true

  # Validations
  before_validation -> { self.location_id = nil }, unless: :location_type?
  before_validation -> { self.config.delete_if { |k, v| !v.present? } }
  validates_presence_of :label, :public_key, :secret_key, :domain
  validates :domain, format: { with: /[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(:[0-9]{1,5})?/ }

  # Scopes
  default_scope { order(last_accessed_at: :desc, updated_at: :desc) }
  scope :enabled, -> { where(enabled: true) }
  scope :disabled, -> { where(enabled: false) }

  # Methods

  def parent
    location || nil
  end

  def url
    "https://#{domain || "wemeditate.com#{"/" + locale if locale != 'en'}"}/map"
  end

  def locale
    config&.dig(:locale)
  end

end
