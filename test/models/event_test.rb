require 'test_helper'

class EventTest < ActiveSupport::TestCase

  # Builds an unsaved event with the given recurrence window. time_zone is normally
  # delegated to the area, which we don't need for recurrence calculations.
  def build_event(start_date:, end_date:, start_time: '18:00', type: 'weekly_1')
    event = OfflineEvent.new(
      category: :dropin,
      recurrence_data: { type: type, start_date: start_date, end_date: end_date, start_time: start_time },
    )
    event.define_singleton_method(:time_zone) { 'UTC' }
    event
  end

  test 'last_recurrence_at returns the final occurrence of a finite recurrence' do
    event = build_event(start_date: '2024-01-03', end_date: '2024-03-01')

    assert_equal Time.utc(2024, 2, 28, 18, 0), event.last_recurrence_at
  end

  test 'last_recurrence_at returns nil for an infinite recurrence' do
    event = build_event(start_date: '2024-01-03', end_date: nil)

    assert_nil event.last_recurrence_at
  end

  # A recurrence ending on its start date yields no occurrences at all, because
  # :until is midnight at the start of that day. The event still reports
  # should_finish?, so the CMS has to render it with no date to show.
  test 'last_recurrence_at returns nil when the recurrence has no occurrences' do
    event = build_event(start_date: '2024-01-03', end_date: '2024-01-03')

    assert_empty event.recurrence.events.to_a
    assert event.should_finish?
    assert_nil event.last_recurrence_at
  end

end
