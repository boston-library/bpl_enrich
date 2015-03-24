require 'test_helper'

class AuthoritiesTest < ActiveSupport::TestCase
  def test_parse_language
    result = BplEnrich::Authorities.parse_language('eng')
    assert_equal 'English', result[:label]
    assert_equal 'http://id.loc.gov/vocabulary/iso639-2/eng', result[:uri]

    result = BplEnrich::Authorities.parse_language('English')
    assert_equal 'English', result[:label]
    assert_equal 'http://id.loc.gov/vocabulary/iso639-2/eng', result[:uri]
  end

  def test_parse_role

    result = BplEnrich::Authorities.parse_role('Contributor')
    assert_equal 'Contributor', result[:label]
    assert_equal 'http://id.loc.gov/vocabulary/relators/ctb', result[:uri]

    #FIXME: Using URI doesn't seem to work in this vocab?
    #result = BplEnrich::Authorities.parse_role('ctb')
    #assert_equal 'Contributor', result[:label]
    #assert_equal 'http://id.loc.gov/vocabulary/relators/ctb', result[:uri]
  end

  def test_parse_name_for_role

    result = BplEnrich::Authorities.parse_name_for_role('Steven Anderson (Contributor)')
    assert_equal 'Steven Anderson', result[:name]
    assert_equal 'Contributor', result[:label]
    assert_equal 'http://id.loc.gov/vocabulary/relators/ctb', result[:uri]

    result = BplEnrich::Authorities.parse_name_for_role('Steven Anderson (Painter)')
    assert_equal 'Steven Anderson (Painter)', result[:name]
    assert_equal nil, result[:label]
    assert_equal nil, result[:uri]

    #Special non-Ascii character check
    result = BplEnrich::Authorities.parse_name_for_role('Sully, François (Photographer)')
    assert_equal 'Sully, François', result[:name]
    assert_equal 'Photographer', result[:label]
    assert_equal 'http://id.loc.gov/vocabulary/relators/pht', result[:uri]

    result = BplEnrich::Authorities.parse_name_for_role('Narrator: Gina Snyder')
    assert_equal 'Gina Snyder', result[:name]
    assert_equal 'Narrator', result[:label]
    assert_equal 'http://id.loc.gov/vocabulary/relators/nrt', result[:uri]

    result = BplEnrich::Authorities.parse_name_for_role('Producer: Reading Public Library')
    assert_equal 'Reading Public Library', result[:name]
    assert_equal 'Producer', result[:label]
    assert_equal 'http://id.loc.gov/vocabulary/relators/pro', result[:uri]


  end


end