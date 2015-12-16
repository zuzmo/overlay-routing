class Logger

	def self.info(entry)
		STDERR.puts(entry)
	end

	def self.print(entry)
		STDERR.print(entry)
	end

	def self.warn(entry)
		STDERR.puts(entry)
	end

	def self.debug(entry)
		STDERR.puts(entry)
	end

	def self.error(entry)
		STDERR.puts(entry)
	end

end