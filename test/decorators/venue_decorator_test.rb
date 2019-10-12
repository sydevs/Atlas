# frozen_string_literal: true

require 'test_helper'

class VenueDecoratorTest < ActiveSupport::TestCase
  def setup
    @venue = Venue.first.extend VenueDecorator
  end

  test "region name helpers" do
    assert_equal @venue.province_name, 'Arizona'
    assert_equal @venue.country_name, 'United States of America'
  end
end
