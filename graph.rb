# Comments
class Graph

  def initialize
    @adjacency_map = Hash.new
  end

  # Adds two directed edges to appear as a non-directed edge
  def add_edge(src, dst, cost)
    add_directed_edge(src, dst, cost)
    add_directed_edge(dst, src, cost)
  end

  # Adds or updates a directed edge with the specified cost
  def add_directed_edge(src, dst, cost)
    if @adjacency_map.has_key?(src)
      map = @adjacency_map[src]
      map[dst] = cost
    else
      @adjacency_map[src] = {dst => cost}
    end
  end



  def get_neighbors(src)
    @adjacency_map[src]
  end

  def get_cost(src, dst)
    @adjacency_map[src][dst]
  end

  def get_all_nodes
    @adjacency_map.keys
  end

  def to_s
    @adjacency_map.to_s
  end

end