# frozen_string_literal: true

require 'test_helper'

class RegionDecoratorTest < ActiveSupport::TestCase

  def setup
    @region = Region.new.extend RegionDecorator
  end

  test 'label helper' do
    assert_equal RegionDecorator.get_name('AZ', 'US'), 'Arizona'
    assert_equal RegionDecorator.get_name('CA', 'US'), 'California'
    assert_equal RegionDecorator.get_name('BC', 'CA'), 'British Columbia'

    assert_equal RegionDecorator.get_label('AZ', 'US'), 'Arizona, US'
    assert_equal RegionDecorator.get_label('CA', 'US'), 'California, US'
    assert_equal RegionDecorator.get_label('BC', 'CA'), 'British Columbia, CA'
  end

end
