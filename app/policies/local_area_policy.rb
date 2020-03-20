class LocalAreaPolicy < RegionPolicy

  def new_association? association = nil
    return nil if association == :events

    %i[managers venues].include?(association) && super
  end

  def autocomplete?
    user.present?
  end

end
