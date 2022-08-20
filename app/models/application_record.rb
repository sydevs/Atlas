class ApplicationRecord < ActiveRecord::Base

  self.abstract_class = true

  include Searchable
  include Parentable
end
