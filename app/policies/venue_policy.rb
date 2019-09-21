
class VenuePolicy < DatabasePolicy
  def new?
    #(record.province.present? || record.local_area.present?) && (user.administrator? || user.regions.present?)
    (record.province.present?) && (user.administrator? || user.regions.present?)
  end

  def create?
    user.administrator? || record.managed_by?(user)
  end

  def update?
    user.administrator? || record.managed_by?(user)
  end

  def destroy?
    user.administrator? || record.managed_by?(user, super_manager: true)
  end
end
