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

		@dest_path = []
		if @prev[dest] != -1
			print_path(@prev[dest], fin_dest)
		end
		@dest_path.push(dest)

		if dest == fin_dest
			@path[fin_dest] = @dest_path
		end

	end

	def self.src_to_all_dest(graph, src)

		@path_to_all_dest = {}
		graph.get_all_nodes.each do |dest|
			src_to_dest(graph, src, dest)
			@path_to_all_dest[dest] = @path[dest]
		end

		return @path_to_all_dest
	end

	def self.src_to_dest(graph, src, dest)

		@path = {}
		dijkstra(graph, src)
		print_path(dest, dest)

		return @path
	end
	
	def self.forwarding_table(graph, src)

		@link = Hash.new {|h,k| h[k]=[]}
		src_to_all_dest(graph, src)

		@path_to_all_dest.keys.each do |key|
			i = 1
			if key != src
				@path_to_all_dest[key].each do |value|
					if i <= 2
						@link[key] <<  value
						i += 1
					end
				end
			end
		end

		return @link
	end


end
