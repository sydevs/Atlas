# frozen_string_literal: true

require 'test_helper'

class RegistrationDecoratorTest < ActiveSupport::TestCase
  def setup
    @registration = Registration.new.extend RegistrationDecorator
  end

  # test "the truth" do
  #   assert true
  # end
end
