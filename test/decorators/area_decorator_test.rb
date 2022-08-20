# frozen_string_literal: true

require 'test_helper'

class AreaDecoratorTest < ActiveSupport::TestCase

  def setup
    @area = Area.new.extend AreaDecorator
  end

  # test "the truth" do
  #   assert true
  # end

end
