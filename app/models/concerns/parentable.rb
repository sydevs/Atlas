
module Parentable

  extend ActiveSupport::Concern

  included do
  end

  def parent
    nil
  end

  def ancestors
    parent.present? ? parent.ancestors + [parent] : []
  end

end
