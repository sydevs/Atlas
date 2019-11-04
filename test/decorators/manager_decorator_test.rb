# frozen_string_literal: true

require 'test_helper'

class ManagerDecoratorTest < ActiveSupport::TestCase

  def setup
    @manager = Manager.new.extend ManagerDecorator
  end

  # test "the truth" do
  #   assert true
  # end

end
