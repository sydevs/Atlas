class AddRegistrationDeadlineToEvents < ActiveRecord::Migration[6.1]
  def change
    add_column :events, :registration_deadline_at, :datetime
  end
end
