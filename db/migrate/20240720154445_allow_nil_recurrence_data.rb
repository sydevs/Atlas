class AllowNilRecurrenceData < ActiveRecord::Migration[7.0]
  def change
    change_column_null :events, :recurrence_data, true, {}
  end
end
