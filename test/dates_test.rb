require 'test_helper'

class DatesTest < ActiveSupport::TestCase
  def test_date_standardizer

    #Month dates
    result = BplEnrich::Dates.standardize('April 1983')
    assert_equal '1983-04', result[:single_date]
    assert_nil result[:date_range]
    assert_nil result[:date_note]

    result = BplEnrich::Dates.standardize('April 7, 1983')
    assert_equal '1983-04-07', result[:single_date]
    assert_nil result[:date_range]
    assert_nil result[:date_note]

    result = BplEnrich::Dates.standardize('April 7.1983 (Easter)')
    assert_equal '1983-04-07', result[:single_date]
    assert_nil result[:date_range]
    assert_equal 'April 7.1983 (Easter)', result[:date_note]

    result = BplEnrich::Dates.standardize('1983.April.7 (Easter)')
    assert_equal '1983-04-07', result[:single_date]
    assert_nil result[:date_range]
    assert_equal '1983.April.7 (Easter)', result[:date_note]

    result = BplEnrich::Dates.standardize('between April 2014 and May 2014')
    assert_nil result[:single_date]
    assert_equal '2014-04', result[:date_range][:start]
    assert_equal '2014-05', result[:date_range][:end]
    assert_nil result[:date_note]

    result = BplEnrich::Dates.standardize('2000-06')
    assert_equal '2000-06', result[:single_date]
    assert_nil result[:date_range]
    assert_nil result[:date_note]

    result = BplEnrich::Dates.standardize('17 June 1962')
    assert_equal '1962-06-17', result[:single_date]
    assert_nil result[:date_range]
    assert_nil result[:date_note]

    result = BplEnrich::Dates.standardize('1860/10-1862/04')
    assert_nil result[:single_date]
    assert_equal '1860-10', result[:date_range][:start]
    assert_equal '1862-04', result[:date_range][:end]
    assert_nil result[:date_note]


    result = BplEnrich::Dates.standardize('[11-12-1928?]')
    assert_equal '1928-11-12', result[:single_date]
    assert_nil result[:date_range]
    assert_nil result[:date_note]
    assert_equal 'questionable', result[:date_qualifier]

    result = BplEnrich::Dates.standardize('Circa 2000')
    assert_equal '2000', result[:single_date]
    assert_nil result[:date_range]
    assert_nil result[:date_note]
    assert_equal 'approximate', result[:date_qualifier]

    result = BplEnrich::Dates.standardize('1995-01-00')
    assert_equal '1995-01', result[:single_date]
    assert_nil result[:date_range]
    assert_nil result[:date_note]
    assert_nil result[:date_qualifier]

    result = BplEnrich::Dates.standardize('1996-00-00')
    assert_equal '1996', result[:single_date]
    assert_nil result[:date_range]
    assert_nil result[:date_note]
    assert_nil result[:date_qualifier]

    result = BplEnrich::Dates.standardize('1997-00')
    assert_equal '1997', result[:single_date]
    assert_nil result[:date_range]
    assert_nil result[:date_note]
    assert_nil result[:date_qualifier]

    # Example 1 from Woods Hole Scientific Community
    result = BplEnrich::Dates.standardize('1939-04-22/1941-11-30')
    assert_nil result[:single_date]
    assert_equal '1939-04-22', result[:date_range][:start]
    assert_equal '1941-11-30', result[:date_range][:end]
    assert_nil result[:date_qualifier]
    assert_nil result[:date_note]

    # Example 2 from Woods Hole Scientific Community... FIXME: Potentially just 1933?
    result = BplEnrich::Dates.standardize('1933-01-01/1933-12-31')
    assert_nil result[:single_date]
    assert_equal '1933-01-01', result[:date_range][:start]
    assert_equal '1933-12-31', result[:date_range][:end]
    assert_nil result[:date_qualifier]
    assert_nil result[:date_note]

    result = BplEnrich::Dates.standardize('May 1996 to June 1996')
    assert_nil result[:single_date]
    assert_equal '1996-05', result[:date_range][:start]
    assert_equal '1996-06', result[:date_range][:end]
    assert_nil result[:date_qualifier]
    assert_nil result[:date_note]
  end


end