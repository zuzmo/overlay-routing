require 'thread'
require 'logger'

class Logger

	def self.init(node_name)
		File.delete(node_name + '.log') if File.exists?(node_name + '.log')
		@@logger = Logger.new(node_name + '.log')
		@@lock = Mutex.new
	end

	def self.info(entry)
		@@lock.synchronize do
			STDERR.puts(entry)
			@@logger.info(entry)
			
		end
	end

	def self.warn(entry)
		@@lock.synchronize do
			STDERR.puts(entry)
			@@logger.warn(entry)
			
		end
	end

	def self.debug(entry)
		@@lock.synchronize do
			STDERR.puts(entry)
			@@logger.debug(entry)
			
		end
	end

	def self.error(entry)
		@@lock.synchronize do
			STDERR.puts(entry)
			@@logger.error(entry)
			
		end
	end

end