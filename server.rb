require 'socket'


require_relative 'client'
require_relative 'logger'

class Server 

  def initialize(node_name, port, neighbors)
    @node_name = node_name
    @neighbors = neighbors
    @server_socket = TCPServer.open('', port)
    @link_state_thread = nil
    # @clients = Queue.new     # connections accepted by this server
    # @servers = Queue.new     # connections requested to other servers (as client)
  end


  def run
    Thread.new do
      Logger.info("server started")
      loop {
        Thread.start(@server_socket.accept) do |client|
          peeraddr = get_peer_address(client.peeraddr)
          # @clients << client
          Logger.info("accepted connection to #{peeraddr}")
          receive_message(client)
          client.close
        end
      }
    end
  end


  def monitor_link_state
    @link_state_thread = Thread.new do
      if @neighbors == nil    # may not have peers to connect to
        return
      end
      loop {
        @neighbors.each do |ip|
          begin
            # s = TCPSocket.open(ip[1], 7000)
            s = Client.new(ip[1], 7000)
            # Logger.info("connection succeeded to #{ip}")
            s.close
          rescue Exception => e
            Logger.error("#{e} #{ip}")
          end
        end
        sleep(2)
      }
    end
  end


  def receive_message(client_node)
    puts "handling message..."
    # loop {
    #   msg = client.gets.chomp
    #   # TODO: route messages
    #   puts "#{msg}"
    # }
    
  end

  def send_message(server_node, msg)


  end

  def get_peer_address(client)
    client[2]
  end

  def get_address
    @server_socket.addr
  end

  def shutdown
    @server_socket.close
  end

  attr_reader :node_name, :server_socket
end


# server = Server.new('n1', 7000, {})
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