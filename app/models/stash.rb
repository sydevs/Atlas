class Stash < ApplicationRecord

  def self.get key
    value = Stash.where(key: key).limit(1).pluck(:value).first
    value = DateTime.parse(value) if key.ends_with?('_at') && !value.nil?
    value
  end

  def self.set key, value
    Stash.find_or_create_by!(key: key).update_column(:value, value)
  end

end
