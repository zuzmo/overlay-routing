require 'test/unit'

require_relative '../utility'

class UtilityTest < Test::Unit::TestCase

  # Called before every test method runs. Can be used
  # to set up fixture information.
  def setup
    # Do nothing
  end

  # Called after every test method runs. Can be used to tear
  # down fixture information.

  def teardown
    # Do nothing
  end

  # Fake test
  def test_fail

    cost_map, ip_map, interface_map = Utility.read_link_costs('../../overlay-routing/weights.csv')
    puts cost_map
    puts ip_map
    puts interface_map
  end
end