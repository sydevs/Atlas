class AddQuestionsToRegistration < ActiveRecord::Migration[6.1]
  def change
    add_column :registrations, :questions, :jsonb, default: {}
    remove_column :registrations, :comment, :text
  end
end
