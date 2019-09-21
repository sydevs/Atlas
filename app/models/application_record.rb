class ApplicationRecord < ActiveRecord::Base

  include Searchable
  include Parentable
  
  self.abstract_class = true

  def label
    name
  end

end
