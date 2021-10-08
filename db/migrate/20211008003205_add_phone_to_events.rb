class AddPhoneToEvents < ActiveRecord::Migration[6.1]
  def change
    add_column :events, :phone_name, :string
    add_column :events, :phone_number, :string
  end
end
