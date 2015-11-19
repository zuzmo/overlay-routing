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
	# 		maps node names to ip addresses (e.g. 'n1' => '10.0.0.20')
	# 2nd. Hash:
	#		maps ip address to a Hash of ip addresses with their costs 
	#		(e.g. '10.0.0.20' => { '10.0.4.20' => 1 })
	# =========================================================================
	def self.read_link_costs(path)
		hostname_ip_map = Hash.new
		link_cost_map = Hash.new
		File.open(path, 'r') do |f|
			f.each_line do |line|
				line.chomp!
				next if line.empty?
				node_a, ip_a, node_b, ip_b, cost = line.split(',')
				node_a.strip!; ip_a.strip!; node_b.strip!; ip_b.strip!; cost.strip!
				
				hostname_ip_map[node_a] = ip_a
				# hostname_ip_map[node_b] = ip_b

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
		return hostname_ip_map, link_cost_map
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