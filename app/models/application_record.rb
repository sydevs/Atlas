class ApplicationRecord < ActiveRecord::Base

  self.abstract_class = true

  include Searchable
  include Parentable

  def has_region_association?
    respond_to?(:countries) || respond_to?(:provinces) || respond_to?(:local_areas)
  end

end
