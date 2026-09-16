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

  test 'occurs? distinguishes a recurrence that happens from one that never does' do
    assert build_event(start_date: '2024-01-03', end_date: '2024-03-01').occurs?
    assert build_event(start_date: '2024-01-03', end_date: nil).occurs?
    assert_not build_event(start_date: '2024-01-03', end_date: '2024-01-03').occurs?
  end

  test 'set_finish_date uses the last occurrence of an event that happens' do
    event = build_event(start_date: '2024-01-03', end_date: '2024-03-01')
    event.send(:set_finish_date)

    assert_equal Date.new(2024, 2, 28), event.finish_date
    assert_not event.current?
  end

  # Without this an event that never occurs has no finish date, so it stays in the
  # `current` scope and on the map until the status task marks it finished.
  test 'set_finish_date backdates an event that never occurs' do
    event = build_event(start_date: '2024-01-03', end_date: '2024-01-03')
    event.send(:set_finish_date)

    assert_operator event.finish_date, :<, Date.current
    assert_not event.current?
  end

  test 'current? is true while an event has no finish date or a future one' do
    event = build_event(start_date: '2024-01-03', end_date: nil)
    assert event.current?

    event.finish_date = 1.week.from_now
    assert event.current?

    event.finish_date = Date.current
    assert_not event.current?
  end

end
