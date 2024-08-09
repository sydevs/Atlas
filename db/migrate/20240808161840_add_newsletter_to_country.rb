class AddNewsletterToCountry < ActiveRecord::Migration[7.0]
  def change
    add_column :countries, :mailing_list, :jsonb, default: {}, null: false
    add_column :registrations, :mailing_list_subscribed_at, :datetime
  end
end
