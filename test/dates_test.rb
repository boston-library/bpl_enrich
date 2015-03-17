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

    result = BplEnrich::Dates.standardize('1983.April.7 (Easter)')
    assert_equal '1983-04-07', result[:single_date]
    assert_equal nil, result[:date_range]
    assert_equal '1983.April.7 (Easter)', result[:date_note]

    result = BplEnrich::Dates.standardize('between April 2014 and May 2014')
    assert_equal nil, result[:single_date]
    assert_equal '2014-04', result[:date_range][:start]
    assert_equal '2014-05', result[:date_range][:end]
    assert_equal nil, result[:date_note]

    result = BplEnrich::Dates.standardize('2000-06')
    assert_equal '2000-06', result[:single_date]
    assert_equal nil, result[:date_range]
    assert_equal nil, result[:date_note]

    result = BplEnrich::Dates.standardize('17 June 1962')
    assert_equal '1962-06-17', result[:single_date]
    assert_equal nil, result[:date_range]
    assert_equal nil, result[:date_note]
  end


end