require 'test_helper'

class DatesTest < ActiveSupport::TestCase
  def test_date_conversion
    result = BplEnrich::Dates.standardize('April 1983')
    assert_equal '1983-04', result[:single_date]
    assert_equal nil, result[:date_range]
    assert_equal nil, result[:date_note]
  end


end