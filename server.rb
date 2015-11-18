require 'socket'

class Server 

  def initialize(node_name, port)
    @node_name = node_name
    @server = TCPServer.open(port)
    @clients = Hash.new     # connections accepted by this server
    @servers = Hash.new     # connections established to other servers
  end


  def run
    loop {
      Thread.start(@server.accept) do |client|
        listen_messages(client)
      end
    }
  end


  def listen_messages(client)
    loop {
      msg = client.gets.chomp
      puts "#{msg}"
    }
    
  end


end


server = Server.new('n1', 7000)
server.run
# t1 = Thread.new do
#   server = TCPServer.open('10.0.0.20', 7000)
#   puts server.addr
#   loop do
#     Thread.start(server.accept) do |client|
      
#       msg = client.gets.chomp
#       puts "#{msg}"
#       # puts server.addr
#       # puts Thread.current.object_id
#       # client.puts(Time.now.ctime)
#       # client.puts "Closing the connection. Bye!"
#       # client.puts "Other line"
#       # client.close
#     end
#   end
# end

# t1.join





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

# i = 0
# loop do
#   puts "And the script is still running (#{i})..."
#   i += 1
#   sleep 1
# end