require 'socket'

class Client

	def initialize(ip, port)
		@server = TCPSocket.open(ip, port)
		# @request = nil
		# @response = nil
		# receive
		# send
		# @request.join
		# @response.join
	end

	def send(msg)
		@server.puts(msg)
	end

	# def receive
	# 	@response = Thread.new do
	# 		loop {
	# 			msg = @server.gets.chomp
	# 			puts "#{msg}"
	# 		}
	# 	end
	# end


	# def send
	# 	@request = Thread.new do
	# 		loop {
	# 			msg = STDIN.gets.chomp
	# 			puts "#{msg}"
	# 			@server.puts(msg)
	# 		}
	# 	end
	# end

	def close
		@server.close
	end
end