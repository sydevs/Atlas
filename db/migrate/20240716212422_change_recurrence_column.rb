class ChangeRecurrenceColumn < ActiveRecord::Migration[7.0]
  def change
    rename_column :events, :recurrence, :recurrence_type
    add_column :events, :recurrence_data, :json, default: {}, null: false
    add_column :events, :finish_date, :date

    reversible do |dir|
      Event.in_batches.each_record do |event|
        dir.up do
          next if event.inactive_category?

          type = event[:recurrence_type] == 0 ? :daily : :weekly_1
          weekday = %i[monday tuesday wednesday thursday friday saturday sunday][event[:recurrence_type] - 1] unless type == :daily
          start_date = weekday ? (event.start_date + 6.days).beginning_of_week(weekday) : event.start_date
          end_date = weekday && event.end_date ? (event.end_date + 6.days).beginning_of_week(weekday) : event.end_date
          event.update_column(:recurrence_data, {
            type: type,
            start_date: start_date,
            start_time: event.start_time,
            end_date: end_date,
            end_time: event.end_time,
            on: weekday,
          })
        end
        dir.down do
          next if event.inactive_category?
          
          weekday = event.recurrence.starts_at&.strftime("%A")&.downcase
          weekday = %w[sunday monday tuesday wednesday thursday friday saturday].index(weekday)
          event[:recurrence_type] = event.recurrence_type == :day ? :daily : weekday
          event.start_date = event.recurrence_start_date
          event.end_date = event.recurrence_end_date
          event.start_time = event.recurrence_start_time
          event.end_time = event.recurrence_end_time
          event.save!(validate: false)
        end
      end
    end

    remove_column :events, :start_date, :date
    remove_column :events, :end_date, :date
    remove_column :events, :start_time, :string
    remove_column :events, :end_time, :string
    remove_column :events, :recurrence_type, :integer, default: 0
  end
end
