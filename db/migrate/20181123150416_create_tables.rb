class CreateTables < ActiveRecord::Migration[5.1]

  def change
    create_table :venues do |t|
      t.string :name
      t.float :latitude
      t.float :longitude
      t.string :contact_name
      t.string :contact_email
      t.string :street
      t.string :municipality
      t.string :subnational
      t.string :country_code, length: 2
      t.string :postcode
      t.timestamps
    end

    create_table :events do |t|
      t.belongs_to :venue
      t.integer :category, default: 0
      t.string :name
      t.string :room
      t.string :contact_name
      t.string :contact_email
      t.string :description
      t.string :languages, array: true

      t.date :start_date
      t.date :end_date
      t.string :start_time
      t.string :end_time
      t.integer :recurrence, default: 0

      t.timestamps
    end

    add_index :events, :languages, using: 'gin'

    create_table :registrations do |t|
      t.belongs_to :event
      t.string :name
      t.string :email
      t.text :comment
      t.timestamps
    end

    create_table :authorizations do |t|
      t.belongs_to :model, polymorphic: true
      t.string :uuid
      t.timestamps
    end
  end

end
