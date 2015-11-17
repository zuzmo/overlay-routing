require 'socket'

Thread.new do
  server = TCPServer.open(7000)
  loop do
    Thread.start(server.accept) do |client|
      # puts Thread.current.object_id
      client.puts(Time.now.ctime)
      client.puts "Closing the connection. Bye!"
      client.puts "Other line"
      client.close
    end
  end
end





# hostname = 'localhost'
# port = 2000

# Thread.new do
# 	socket = TCPSocket.open(hostname, port)

# 	# line = gets
# 	# put line
# 	puts socket.gets
# 	socket.puts "Client"
# 	socket.puts Thread.current.object_id
# 	socket.close
# end

i = 0
loop do
  puts "And the script is still running (#{i})..."
  i += 1
  sleep 1
end