class LocalAreaPolicy < RegionPolicy

  def new_association? association = nil
    return nil if association == :events # They can't be created, but a notice should be shown, signified by 'nil'

    %i[managers venues].include?(association) && super
  end

  def autocomplete?
    user.present?
  end

end
