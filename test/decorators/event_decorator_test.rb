# frozen_string_literal: true

require 'test_helper'

class EventDecoratorTest < ActiveSupport::TestCase
  def setup
    @event = Event.new.extend EventDecorator
  end

  # test "the truth" do
  #   assert true
  # end
end
