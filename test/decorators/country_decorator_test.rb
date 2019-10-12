# frozen_string_literal: true

require 'test_helper'

class CountryDecoratorTest < ActiveSupport::TestCase
  def setup
    @country = Country.new.extend CountryDecorator
  end

  test "label helper" do
    assert_equal CountryDecorator.get_label('GB'), 'United Kingdom of Great Britain and Northern Ireland'
    assert_equal CountryDecorator.get_label('US'), 'United States of America'
    assert_equal CountryDecorator.get_label('CA'), 'Canada'
  end
end
