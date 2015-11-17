class Utility

	# ===============================================================
	# Reads the global config file and returns a Hash containing the
	# configuration options
	# ===============================================================
	def self.read_config(path)
		options = Hash.new
		File.open(path, 'r') do |f|
			f.each_line do |line|
				key, val = line.split('=')
				key.strip!
				val.strip!
				options[key] = val
			end
		end
		return options
	end

	# ===============================================================
	# Reads the config file containing the cost for each of
	# its outgoing links and returns a Hash with all the costs
	# ===============================================================
  def self.read_link_costs(path)
		link_costs = Hash.new
		File.open(path, 'r') do |f|
			f.each_line do |line|
				ip_address, port, cost = line.split(' ')
				ip_address.strip!; port.strip!; cost.strip!
				link_costs[ip_address] = {port => cost}
			end
		end
		return link_costs
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

# puts Utility.chunkify('costs+costs', 3).class
puts Utility.num_bytes('costs+				      \ncosts')
puts Utility.num_bytes2('costs+\ncosts')