require 'test_helper'

class EventTest < ActiveSupport::TestCase

  # Builds an unsaved event with the given recurrence window. time_zone is normally
  # delegated to the area, which we don't need for recurrence calculations.
  def build_event(start_date:, end_date:, start_time: '18:00', type: 'weekly_1', category: :dropin)
    event = OfflineEvent.new(
      category: category,
      recurrence_data: { type: type, start_date: start_date, end_date: end_date, start_time: start_time },
    )
    event.define_singleton_method(:time_zone) { 'UTC' }
    event
  end

  # One week of a "last Wednesday of the month" event. The dates are the right way
  # round, but the window is too narrow to contain a day the rule matches.
  def build_never_occurring_event
    build_event(type: 'monthly_last', start_date: '2024-01-03', end_date: '2024-01-10')
  end

  test 'last_recurrence_at returns the final occurrence of a finite recurrence' do
    event = build_event(start_date: '2024-01-03', end_date: '2024-03-01')

    assert_equal Time.utc(2024, 2, 28, 18, 0), event.last_recurrence_at
  end

  test 'last_recurrence_at returns nil for an infinite recurrence' do
    event = build_event(start_date: '2024-01-03', end_date: nil)

    assert_nil event.last_recurrence_at
  end

  # The event still reports should_finish?, so the CMS has to be able to render it
  # with no date to show.
  test 'last_recurrence_at returns nil when the recurrence has no occurrences' do
    event = build_never_occurring_event

    assert_empty event.recurrence.events.to_a
    assert event.should_finish?
    assert_nil event.last_recurrence_at
  end

  test 'occurs? distinguishes a recurrence that happens from one that never does' do
    assert build_event(start_date: '2024-01-03', end_date: '2024-03-01').occurs?
    assert build_event(start_date: '2024-01-03', end_date: nil).occurs?
    assert_not build_never_occurring_event.occurs?
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
    event = build_never_occurring_event
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

  test 'an event ending on its start date happens once on that date' do
    event = build_event(start_date: '2024-01-03', end_date: '2024-01-03')

    assert_equal [Time.utc(2024, 1, 3, 18, 0)], event.recurrence.events.to_a.map(&:utc)
  end

  test 'an occurrence falling on the end date is included' do
    event = build_event(start_date: '2024-01-03', end_date: '2024-02-28')

    assert_equal Time.utc(2024, 2, 28, 18, 0), event.last_recurrence_at
  end

  test 'a recurrence with no occurrences is rejected' do
    event = build_never_occurring_event
    event.send(:validate_recurrence_occurs)

    assert_includes event.errors[:end_date], 'does not include any dates when this event happens'
  end

  test 'a recurrence that happens is accepted' do
    event = build_event(start_date: '2024-01-03', end_date: '2024-03-01')
    event.send(:validate_recurrence_occurs)

    assert_empty event.errors[:end_date]
  end

  test 'registration for a course or a one off event closes when it starts' do
    %i[course single concert].each do |category|
      event = build_event(start_date: '2024-01-03', end_date: '2024-02-28', category: category)

      assert_equal Time.utc(2024, 1, 3, 18, 0), event.registration_end_time, category
    end
  end

  test 'registration for a recurring event closes at its final session' do
    %i[dropin festival].each do |category|
      event = build_event(start_date: '2024-01-03', end_date: '2024-02-28', category: category)

      assert_equal Time.utc(2024, 2, 28, 18, 0), event.registration_end_time, category
    end
  end

  test 'registration has no end time without a final session to close at' do
    assert_nil build_event(start_date: '2024-01-03', end_date: nil).registration_end_time

    event = OfflineEvent.new(category: :inactive, recurrence_data: {})
    event.define_singleton_method(:time_zone) { 'UTC' }
    assert_nil event.registration_end_time
  end

end
