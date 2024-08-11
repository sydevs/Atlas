class AddUsersTable < ActiveRecord::Migration[7.0]
  def change
    create_table :users do |t|
      t.string :email, null: false
      t.string :name, null: false
      t.timestamps
    end

    add_reference :registrations, :user, index: true

    reversible do |dir|
      Registration.in_batches.each_record do |registration|
        dir.up do
          registration.user = User.create(email: registration[:email], name: registration[:name])
          registration.save!
        end
        dir.down do
          if registration.user
            registration[:email] = registration.user.email
            registration[:name] = registration.user.name
            registration.save!
          end
        end
      end
    end

    remove_column :registrations, :email, :string
    remove_column :registrations, :name, :string
  end
end
