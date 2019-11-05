# frozen_string_literal: true

require 'test_helper'

class LocalAreaDecoratorTest < ActiveSupport::TestCase

  def setup
    @local_area = LocalArea.new.extend LocalAreaDecorator
  end

  # test "the truth" do
  #   assert true
  # end

end
