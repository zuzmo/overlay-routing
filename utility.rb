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
	
end