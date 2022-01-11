class AddLastLoginToManagers < ActiveRecord::Migration[6.1]
  def change
    add_column :managers, :last_login_at, :datetime
    add_column :managers, :email_verified, :boolean
    add_column :managers, :email_verification_sent_at, :datetime
  end
end
