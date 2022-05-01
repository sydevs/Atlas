class ReplaceRegistrationDeadlineWithLimit < ActiveRecord::Migration[6.1]
  def change
    remove_column :events, :registration_deadline_at, :datetime
    add_column :events, :registration_limit, :integer
  end
end
