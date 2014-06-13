require 'test_helper'

class DatesTest < ActiveSupport::TestCase
  def test_date_standardizer

    #Month dates
    result = BplEnrich::Dates.standardize('April 1983')
    assert_equal '1983-04', result[:single_date]
    assert_equal nil, result[:date_range]
    assert_equal nil, result[:date_note]

    result = BplEnrich::Dates.standardize('April 7, 1983')
    assert_equal '1983-04-07', result[:single_date]
    assert_equal nil, result[:date_range]
    assert_equal nil, result[:date_note]

    result = BplEnrich::Dates.standardize('April 7.1983 (Easter)')
    assert_equal '1983-04-07', result[:single_date]
    assert_equal nil, result[:date_range]
    assert_equal 'April 7.1983 (Easter)', result[:date_note]

    result = BplEnrich::Dates.standardize('1983.7.April (Easter)')
    assert_equal '1983-04-07', result[:single_date]
    assert_equal nil, result[:date_range]
    assert_equal 'April 7.1983 (Easter)', result[:date_note]
  end


end