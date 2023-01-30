class AddRegistrationQuestionsToEvent < ActiveRecord::Migration[6.1]
  def change
    add_column :events, :registration_question, :integer, null: false, default: 1
  end
end
