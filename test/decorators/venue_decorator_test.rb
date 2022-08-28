# frozen_string_literal: true

require 'test_helper'

class VenueDecoratorTest < ActiveSupport::TestCase

  def setup
    @venue = Venue.first.extend VenueDecorator
  end

  # test "the truth" do
  #   assert true
  # end

end
