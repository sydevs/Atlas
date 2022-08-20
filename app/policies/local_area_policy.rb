class LocalAreaPolicy < RegionPolicy

  def new_association? association = nil, query = {}
    return nil if association == :events && query[:online] != true  # They can't be created, but a notice should be shown, signified by 'nil'

    %i[managers venues events].include?(association) && super
  end

  def mappable?
    true
  end

  def autocomplete?
    user.present?
  end

end
