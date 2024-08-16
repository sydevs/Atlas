class ApplicationRecord < ActiveRecord::Base

  self.abstract_class = true

  include Searchable
  include Parentable

  def canonical_host
    try(:canonical_domain) || wemeditate_host
  end

  def equals? obj
    obj.class == self.class && obj.id == self.id
  end

  private

    def wemeditate_host
      return 'localhost:3000' if Rails.env.development?
      return 'wemeditate.com' if I18n.locale.to_sym == :en

      "wemeditate.com/#{I18n.locale}"
    end
end
