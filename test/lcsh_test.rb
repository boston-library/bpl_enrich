require 'test_helper'

class LCSHTest < ActiveSupport::TestCase
  def test_lcsh_standardizer
    result = BplEnrich::LCSH.standardize('Farming -- Mass.')
    assert_equal 'Farming--Mass', result
  end


end