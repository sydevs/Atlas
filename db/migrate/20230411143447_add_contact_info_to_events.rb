class AddContactInfoToEvents < ActiveRecord::Migration[6.1]
  def up
    add_column :events, :contact_info, :jsonb, default: {}, null: false

    Event.where.not(phone_number: nil).each do |event|
      event.update! contact_info: {
        phone_number: event.phone_number,
        phone_name: event.phone_name,
      }
    end
  end
  
  def down
    remove_column :events, :contact_info
  end
end
