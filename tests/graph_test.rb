require_relative '../graph'
require 'test/unit'

class GraphTest < Test::Unit::TestCase

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

  #
  def test_add_directed_edge
    graph = Graph.new
    graph.add_edge('a', 'b', 2)

    graph.add_edge('a', 'c', 2)

    graph.add_edge('b', 'c', 1)

    graph.add_edge('b', 'd', 5)

    graph.add_edge('c', 'd', 5)


    assert(graph.get_cost('a','b') == 2)
    assert(graph.get_cost('b','a') == 2)

    assert(graph.get_cost('a','c') == 2)
    assert(graph.get_cost('c','a') == 2)

    assert(graph.get_cost('b','c') == 1)
    assert(graph.get_cost('c','b') == 1)

    assert(graph.get_cost('b','d') == 5)
    assert(graph.get_cost('d','b') == 5)

    assert(graph.get_cost('c','d') == 5)
    assert(graph.get_cost('d','c') == 5)

    assert_nil(graph.get_cost('a', 'x'))

  end
end