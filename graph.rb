require_relative 'utility'

# TODO:
# 1. Sort the hash by keys of keys.
#
class Graph

  def initialize(link_state_table)
    @adjacency_map = {}
    @dist = {}
    @visited = {}
    @prev = {}
    @path_to_all_dest = {}
    @path_to_all_dest = {}
    @dest_path = []

    create_graph(link_state_table)
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

  # Creates the graph from the weights file.
  def create_graph(cost_map)

    cost_map.keys.each do |src|
      cost_map[src].each do |dest, cost|
        if(cost != "Infinity")
          add_directed_edge(src, dest, cost)
        end
      end
    end
  end

  def min_distance

    min = Float::INFINITY
    vertex = String.new
    @visited.each do |key, value|
      value = @dist[key]
      if (!@visited[key]) && (value <= min)
        min = value
        vertex = key
      end
    end

    vertex
  end

  def dijkstra( src)


    cost = 0
    for v in get_all_nodes
      @dist[v] = Float::INFINITY
      @visited[v] = false
      @prev[v] = -1
    end

    @dist[src] = 0

    get_all_nodes.each do |vertex|
      u = min_distance
      @visited[u] = true

      get_neighbors(u).each do |v, array|
        alt = @dist[u] + get_cost(u, v)
        if alt < @dist[v]
          @dist[v] = alt
          @prev[v] = u
        end
      end
    end

  end

  def print_path(dest, fin_dest)


    @dest_path = []
    if @prev[dest] != -1
      print_path(@prev[dest], fin_dest)
    end
    @dest_path.push(dest)

    if dest == fin_dest
      @path_to_dest[fin_dest] = @dest_path
    end

  end

  def src_to_all_dest( src)


    get_all_nodes.each do |dest|
      src_to_dest( src, dest)
      @path_to_all_dest[dest] = @path_to_dest[dest]
    end

    @path_to_all_dest
  end

  def src_to_dest( src, dest)

    @path_to_dest = {}
    dijkstra( src)
    print_path(dest, dest)

    return @path_to_dest[dest].to_a, @dist[dest]
  end

  def forwarding_table( src)

    link = Hash.new {|h,k| h[k]=[]}
    src_to_all_dest( src)

    @path_to_all_dest.keys.each do |key|
      i = 1
      if key != src
        @path_to_all_dest[key].each do |value|
          if i <= 2
            link[key] <<  value
            i += 1
          end
        end
      end
    end


    link
  end

  def dumptable graph, file
    cost_map, ip_map, interfaces_map =  Utility.read_link_costs("./s1/weights.csv")

    src_node = "n1"

    table = forwarding_table( src_node)
    file_contents = String.new

    table.keys.each do |dest_node|
      path, cost = src_to_dest( src_node, dest_node)

      # Printing DUMPTABLE
      next_hop_node = table[dest_node][1]
      next_hop_ip = ip_map[src_node][next_hop_node]

      for src_ip in interfaces_map[src_node]
        for dest_ip in interfaces_map[dest_node]
          file_contents << "#{src_ip} #{dest_ip} #{next_hop_ip} #{cost}\n"
        end
      end


    end


    Utility.write_string_to_file(file,file_contents)
  end

end


link_state_table = {"n1"=>{"n2"=>1, "n3"=>1}, "n2"=>{"n1"=>1, "n3"=>1, "n4"=>1}, "n3"=>{"n1"=>1, "n2"=>1, "n4"=>1}, "n4"=>{"n2"=>1, "n3"=>1}}
graph = Graph.new(link_state_table)
puts graph
puts graph.forwarding_table( "n1")
