class AddExpirationPeriodToEvents < ActiveRecord::Migration[6.1]
  def change
    add_column :events, :expiration_period, :integer, default: 3, null: false
    add_column :events, :verification_streak, :integer, default: 0, null: false
  end
end
