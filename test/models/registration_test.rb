require 'test_helper'

class RegistrationTest < ActiveSupport::TestCase

  # Friday 19:00 in Vancouver, which is Saturday 02:00 in UTC.
  def build_registration
    event = OfflineEvent.new
    event.define_singleton_method(:time_zone) { 'America/Vancouver' }
    Registration.new(event: event, starting_at: Time.utc(2026, 9, 26, 2, 0)).extend(RegistrationDecorator)
  end

  test 'the starting date is the day of the session in the event time zone' do
    registration = build_registration

    assert_equal Date.new(2026, 9, 25), registration.starting_date
    assert_equal 'Friday', registration.starting_at_weekday
  end

end
