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


	def receive
		@response = Thread.new do
			loop {
				msg = @server.gets.chomp
				puts "#{msg}"
			}
		end
	end


	def send
		@request = Thread.new do
			loop {
				msg = STDIN.gets.chomp
				puts "#{msg}"
				@server.puts(msg)
			}
		end
	end

	def close
		@server.close
	end
<<<<<<< HEAD
=======


>>>>>>> 931fc86e87725ae7fa9eb1d6b2f76dd0744f7a4c
end

# ip = '10.0.0.20'
# port = 7000
<<<<<<< HEAD
# s = Client.new(ip, port)
=======
# s = Client.new(ip,port)
>>>>>>> 931fc86e87725ae7fa9eb1d6b2f76dd0744f7a4c

# while line = gets
# line = gets
# puts line.chop
# end

# msg = 'hi'
# s.puts(msg)

# while line = s.gets
#   print line
# end

# s.send 'Hi from client'
# STDOUT.flush
# msg = s.gets
# print msg
# s.puts Thread.current.object_id


# s.close