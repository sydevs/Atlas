module HasClient

  extend ActiveSupport::Concern

  included do
    # has_one :client, inverse_of: :location
  end

  def client_bounds
    [[bounds[2], bounds[0]], [bounds[3], bounds[1]]] if respond_to?(:bounds)
  end

  def canonical_domain
    # client&.dig('config', 'domain')
  end

end
