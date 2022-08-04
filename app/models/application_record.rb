class ApplicationRecord < ActiveRecord::Base

  self.abstract_class = true

  include Searchable
  include Parentable

  def region_association?
    respond_to?(:countries) || respond_to?(:provinces)
  end

end
