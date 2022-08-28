# frozen_string_literal: true

require 'test_helper'

class RegionDecoratorTest < ActiveSupport::TestCase

  def setup
    @region = Region.new.extend RegionDecorator
  end

end
