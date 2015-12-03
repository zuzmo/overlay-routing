require 'io/console'

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
				key, val = line.split('=')
				key.strip!; val.strip!
				options[key] = val
			end
		end
		options
	end

	# =========================================================================
	# Reads the config file containing the cost for each of
	# its outgoing links and returns two Hash of Hashes.
	# 1st. Hash (cost_map):
	#		(e.g. { 'n1' => { 'n2' => 1, 'n3' => 1 },
	#				'n2' => { 'n1' => 1, 'n3' => 1 } }
	# 2nd. Hash (ip_map):
	#		(e.g. { 'n1' => { 'n2' => '10.0.0.21', 'n3' => '10.0.4.21' },
	#				'n2' => { 'n1' => '10.0.0.20', 'n3' => '10.0.1.21' } }
	# 3rd. Hash (interfaces_map):
	# 		(e.g. { 'n1' => ['10.0.0.20', '10.0.4.20'], 
	#  				'n2' => ['10.0.0.21']})
	# =========================================================================
	def self.read_link_costs(path)
		cost_map = Hash.new
		ip_map = Hash.new
		interfaces_map = Hash.new
		File.open(path, 'r') do |f|
			f.each_line do |line|
				line.chomp!
				next if line.empty?
				node_a, ip_a, node_b, ip_b, cost = line.split(',')
				node_a.strip!; ip_a.strip!; node_b.strip!; ip_b.strip!; cost.strip!
				
				# 1st map
				if cost_map.has_key?(node_a)
					neighbors_map = cost_map[node_a]
					neighbors_map[node_b] = cost.to_i
				else
					cost_map[node_a] = { node_b => cost.to_i }
				end

				if cost_map.has_key?(node_b)
					neighbors_map = cost_map[node_b]
					neighbors_map[node_a] = cost.to_i
				else
					cost_map[node_b] = { node_a => cost.to_i }
				end

				# 2nd map
				if ip_map.has_key?(node_a)
					neighbors_map = ip_map[node_a]
					neighbors_map[node_b] = ip_b
				else
					ip_map[node_a] = { node_b => ip_b }
				end

				if ip_map.has_key?(node_b)
					neighbors_map = ip_map[node_b]
					neighbors_map[node_a] = ip_a
				else
					ip_map[node_b] = { node_a => ip_a }
				end

				# 3rd map
				if interfaces_map.has_key?(node_a)
					interface_arr = interfaces_map[node_a]
					interface_arr << ip_a
				else
					interfaces_map[node_a] = [ip_a]
				end

				if interfaces_map.has_key?(node_b)
					interface_arr = interfaces_map[node_b]
					interface_arr << ip_b
				else
					interfaces_map[node_b] = [ip_b]
				end

			end
		end
		return cost_map, ip_map, interfaces_map
	end

	# =========================================================================
	# Reads the file containing the node ports and returns a Hash
	# (e.g. { 'n1' => 5000, 'n2' => 5001)
	# =========================================================================
	def self.read_ports(path)
		node_port_map = Hash.new
		File.open(path, 'r') { |f|
			f.each_line do |line|
				line.chomp!
				next if line.empty?
				node_name, port = line.split('=')
				node_name.strip!; port.strip!
				node_port_map[node_name] = port
			end
		}
		node_port_map
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

	def self.read_bytes(fname)
		s = File.open(fname,'rb'){ |f| f.read }
		# s.encoding
		arr = s.unpack('H2'*s.size)
		str = arr*''
		str
	end

	def self.write_bytes(fname, bytes)
		File.write(fname, bytes)
	end

end