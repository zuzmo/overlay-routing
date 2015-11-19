require_relative '../dijkstras'
require 'test/unit'

class DijkstrasTest < Test::Unit::TestCase

  def test_src_to_all_dest
    graph = Graph.new
    graph.add_edge('a', 'b', 2)
    graph.add_edge('a', 'c', 2)
    graph.add_edge('b', 'c', 1)
    graph.add_edge('b', 'd', 5)
    graph.add_edge('c', 'd', 5)


    path_to_dest = {}
    path_to_dest["a"] = ["a"]
    path_to_dest["b"] = ["a", "b"]
    path_to_dest["c"] = ["a", "c"]
    path_to_dest["d"] = ["a", "c", "d"]
    assert(Dijkstras.src_to_all_dest(graph, 'a') == path_to_dest)

  end

  def test_src_to_dest
    graph = Graph.new
    graph.add_edge('a', 'b', 2)
    graph.add_edge('a', 'c', 2)
    graph.add_edge('b', 'c', 1)
    graph.add_edge('b', 'd', 5)
    graph.add_edge('c', 'd', 5)

    path_to_dest = {}
    path_to_dest["d"] = ["a", "c", "d"]
    assert(Dijkstras.src_to_dest(graph, 'a', 'd') == path_to_dest)

  end
end