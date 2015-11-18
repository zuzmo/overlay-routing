#!/usr/bin/env ruby
require_relative 'graph'

class Dijkstras

	def self.min_distance()

		min = Float::INFINITY
		vertex = String.new
		@visited.each do |key, value|
			value = @dist[key]
			if (!@visited[key]) && (value <= min)
				min = value
				vertex = key
			end
		end

		return vertex
	end

	def self.dijkstra(graph, src)

		@dist = {}
		@visited = {}
		@prev = {}

		for v in graph.get_all_nodes
			@dist[v] = Float::INFINITY
			@visited[v] = false
			@prev[v] = -1
		end

		@dist[src] = 0

		graph.get_all_nodes.each do |vertex|
			u = min_distance
			@visited[u] = true

			graph.get_neighbors(u).each do |v, array|
				alt = @dist[u] + graph.get_cost(u, v)
				if (alt < @dist[v])
					@dist[v] = alt
					@prev[v] = u
				end
			end
		end

	end


	def self.print_path(dest, fin_dest)
		@path = {}
		@dest_path = []
		if @prev[dest] != -1
			print_path(@prev[dest], fin_dest)
		end
		@dest_path.push(dest)

		if dest == fin_dest
			@path[fin_dest] = @dest_path
			puts @path
		end

	end

	def self.src_to_all_dest(graph, s)
		dijkstra(graph, s)

		graph.get_all_nodes.each do |dest|
			print_path(dest, dest)
		end

	end

	def self.src_to_dest(graph, src, dest)
		dijkstra(graph, src)
		print_path(dest, dest)
	end

end

graph = Graph.new
graph.add_edge('a', 'b', 2)
graph.add_edge('a', 'c', 5)
graph.add_edge('a', 'd', 1)

graph.add_edge('b', 'c', 3)
graph.add_edge('b', 'd', 2)

graph.add_edge('c', 'e', 1)

graph.add_edge('d', 'c', 3)
graph.add_edge('d', 'e', 1)

graph.add_edge('f', 'c', 5)
graph.add_edge('f', 'e', 2)

puts "\nTarget\tPath\n\n"
Dijkstras.src_to_all_dest(graph, 'a')
puts
Dijkstras.src_to_dest(graph, 'f', 'a')