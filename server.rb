require 'socket'

require_relative 'client'
require_relative 'logger'
require_relative 'message_builder'
require_relative 'utility'

class Server


  def initialize(node_name, port, update_interval, weight_file)
    @node_name = node_name
    @update_interval = update_interval
    @weight_file = weight_file
    @link_costs_map = nil                 # init in do_routing_update
    @neighbors = nil                      # init in do_routing_update
    @server_socket = TCPServer.open('', port)
    @routing_update_thread = nil
    
    # @clients = Queue.new     # connections accepted by this server
    # @servers = Queue.new     # connections requested to other servers (as client)
  end


  def run
    Thread.new do
      Logger.info("server started")
      loop {
        Thread.start(@server_socket.accept) do |client|
          peeraddr = get_peer_address(client)
          # @clients << client
          Logger.info("accepted connection to #{peeraddr}")
          receive_message(client)
          client.close
        end
      }
    end
  end

  def do_routing_update
    @routing_update_thread = Thread.new do
      loop {
        do_link_state_algorithm
        sleep(@update_interval)
      }
    end
  end

  def do_link_state_algorithm
    Logger.info("updating routing table")
    @link_costs_map, _ = Utility.read_link_costs(@weight_file)
    @neighbors = @link_costs_map[node_name]
    flood_message = MessageBuilder.create_flood_message(@node_name, @neighbors)
    neighbor_names = @neighbors.clone


    # neighbor_names.each{ |n| puts n[0], flood_message }
    # puts neighbor_names
    for neighbor in neighbor_names.each do
       send_message(neighbor[0],flood_message)         
    end

  end

  def do_forced_link_state
    Thread.kill(@routing_update_thread)
    do_routing_update()
  end


  def monitor_link_state
    Thread.new do
      if @neighbors == nil    # may not have peers to connect to
        return
      end
      loop {
        @neighbors.each do |ip|
          begin
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
    puts client_node.read

    # loop {
    #   msg = client.gets.chomp
    #   # TODO: route messages
    #   puts "#{msg}"
    # }
    
  end

  def send_message(server_node, msg)
    Thread.new do
      # 1. Check if msg is for this server
      # 2. Check if node exists in forwarding table
      # 3. If not, the node is unreachable (print error)
      # ===========================server_ip = server_node[1]  if array

      server_ip = get_address(server_node)
      if server_ip == 'unreachable'
        puts 'SENDMSG ERROR: HOST UNREACHABLE'
      else
        begin
          s = Client.new(server_ip, 7000)
          s.send(msg)
          s.close
        rescue Exception => e
          Logger.error("#{e} #{server_ip}")
        end
      end

    end
  end


   def get_peer_address(client)
    client.peeraddr[2]
  end


  def get_address(node)
    if node == @node_name
      return '0.0.0.0'    # this server's address
    end 
    @neighbors.each do |n|
      if n[0] == node 
        return n[1]
      end
    end
    return 'unreachable'
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