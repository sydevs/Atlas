class ApplicationRecord < ActiveRecord::Base

  self.abstract_class = true

  include Searchable
  include Parentable

  def canonical_host
    try(:canonical_domain) || (Rails.env.development? ? 'localhost:3000' : "wemeditate.com/#{I18n.locale}")
  end
end
