class AddExternalRegistrationToEvents < ActiveRecord::Migration[5.2]
  def change
    add_column :events, :registration_mode, :integer, default: 0
    add_column :events, :registration_url, :string
  end
end
