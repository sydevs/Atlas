class ApplicationRecord < ActiveRecord::Base

  self.abstract_class = true

  include Searchable
  include Parentable

  def canonical_url
    Rails.env.development? ? 'localhost:3000' : 'wemeditate.com'
  end
end
