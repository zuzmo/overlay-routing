class Utility

	# =========================================================================
	# Reads the global config file and returns a Hash containing the
	# configuration options
	# =========================================================================
	def self.read_config(path)
		options = Hash.new
		File.open(path, 'r') do |f|
			f.each_line do |line|
				line.chomp!
				next if line.empty?
				key, val = line.split(',')
				key.strip!
				val.strip!
				options[key] = val
			end
		end
		return options
	end

	# =========================================================================
	# Reads the config file containing the cost for each of
	# its outgoing links and returns two Hashes.
	# 1st. Hash:
	# 		maps node names to an array of arrays containing interfaces 
	#		(e.g. {'n1' => [['n2', '10.0.0.21'], [n3 , '10.0.4.21']] })
	# 2nd. Hash:
	#		maps ip address to a Hash of ip addresses with their costs 
	#		(e.g. '10.0.0.20' => { '10.0.4.20' => 1 })
	# =========================================================================
	def self.read_link_costs_old(path)
		neighbors_map = Hash.new
		link_cost_map = Hash.new
		File.open(path, 'r') do |f|
			f.each_line do |line|
				line.chomp!
				next if line.empty?
				node_a, ip_a, node_b, ip_b, cost = line.split(',')
				node_a.strip!; ip_a.strip!; node_b.strip!; ip_b.strip!; cost.strip!
				
				if neighbors_map.has_key?(node_a)
					ip_array = neighbors_map[node_a]
					ip_array.push(Array[node_b, ip_b, cost])
				else
					neighbors_map[node_a] = Array[Array[node_b, ip_b, cost]]
				end

				# TODO change code here
				if link_cost_map.has_key?(ip_a)
					sub_map = @link_cost_map[ip_a]
					sub_map[ip_b] = cost
				else
					link_cost_map[ip_a] = {ip_b => cost}
				end
				# if link_cost_map.has_key?(ip_b)
				# 	sub_map = @link_cost_map[ip_b]
				# 	sub_map[ip_a] = cost
				# else
				# 	link_cost_map[ip_b] = {ip_a => cost}
				# end
			end
		end
		return neighbors_map, {}
	end

	# =========================================================================
	# Reads the config file containing the cost for each of
	# its outgoing links and returns two Hashes.
	# 1st. Hash:
	# 		maps source name to its neighbors including costs
	#		(e.g. {'n1' => [['n2', '10.0.0.21', 1], [n3 , '10.0.4.21', 2]] })
	# 2nd. Hash:
	#		maps ip address to a Hash of ip addresses with their costs 
	#		(e.g. '10.0.0.20' => { '10.0.4.20' => 1 })
	# =========================================================================
	def self.read_link_costs(path)
		neighbors_map = Hash.new
		link_cost_map = Hash.new
		File.open(path, 'r') do |f|
			f.each_line do |line|
				line.chomp!
				next if line.empty?
				node_a, ip_a, node_b, ip_b, cost = line.split(',')
				node_a.strip!; ip_a.strip!; node_b.strip!; ip_b.strip!; cost.strip!
				
				if neighbors_map.has_key?(node_a)
					ip_array = neighbors_map[node_a]
					ip_array.push(Array[node_b, ip_b, cost])
				else
					neighbors_map[node_a] = Array[Array[node_b, ip_b, cost]]
				end

				if neighbors_map.has_key?(node_b)
					ip_array = neighbors_map[node_b]
					ip_array.push(Array[node_a, ip_a, cost])
				else
					neighbors_map[node_b] = Array[Array[node_a, ip_a, cost]]
				end

				# TODO change code here
				if link_cost_map.has_key?(ip_a)
					sub_map = @link_cost_map[ip_a]
					sub_map[ip_b] = cost
				else
					link_cost_map[ip_a] = {ip_b => cost}
				end
				# if link_cost_map.has_key?(ip_b)
				# 	sub_map = @link_cost_map[ip_b]
				# 	sub_map[ip_a] = cost
				# else
				# 	link_cost_map[ip_b] = {ip_a => cost}
				# end
			end
		end
		return neighbors_map, {}
	end

	# =========================================================================
	# Creates a file if it doesn't already exists and writes a string to it.
	# Params:
	#        +file_name -> the name of the file
	#        +string -> the string to write to the file
	# =========================================================================
	def self.write_string_to_file(file_name,string)
		File.open("#{file_name}",'w'){ |f|
			f.write(string)
		}
	end

	# Returns the size of the specified string in bytes
	def self.num_bytes(str)
		str.bytesize
	end

	# Returns the size of the specified string in bytes
	def self.num_bytes2(str)
		str.length
	end

	# Returns an array of chunks
	def self.chunkify(str, chunk_size)
		str.scan(/.{1,#{chunk_size}}/)
	end

end