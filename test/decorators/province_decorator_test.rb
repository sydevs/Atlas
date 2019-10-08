# frozen_string_literal: true

require 'test_helper'

class ProvinceDecoratorTest < ActiveSupport::TestCase
  def setup
    @province = Province.new.extend ProvinceDecorator
  end

  test "label helper" do
    assert_equal ProvinceDecorator.get_name('AZ', 'US'), 'Arizona'
    assert_equal ProvinceDecorator.get_name('CA', 'US'), 'California'
    assert_equal ProvinceDecorator.get_name('BC', 'CA'), 'British Columbia'
    
    assert_equal ProvinceDecorator.get_label('AZ', 'US'), 'Arizona, US'
    assert_equal ProvinceDecorator.get_label('CA', 'US'), 'California, US'
    assert_equal ProvinceDecorator.get_label('BC', 'CA'), 'British Columbia, CA'
  end
end
