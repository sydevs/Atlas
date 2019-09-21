
class DatabasePolicy < ApplicationPolicy
  def new?
    record.respond_to?(:parent) ? record.parent.present? : true
  end

  def index_registrations?
    user.administrator?
  end

  def index_events?
    user.administrator?
  end

  def index_venues?
    user.administrator?
  end

  def index_managers?
    user.administrator?
  end

  def index_regions?
    user.present?
  end
end
