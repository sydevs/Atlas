class AddUuidToRegistration < ActiveRecord::Migration[7.0]
  def change
    enable_extension 'pgcrypto' unless extension_enabled?('pgcrypto')
    add_column :registrations, :uuid, :uuid, default: 'gen_random_uuid()', null: false
    add_column :registrations, :next_reminder_at, :datetime
    Registration.in_batches.each_record do |registration|
      registration.set_reminder
      registration.next_reminder_at ||= registration.starting_at - 1.day
      registration.save!
    end

    change_column_null :registrations, :next_reminder_at, false
  end
end
