require 'socket'
require 'json'
require 'thread'

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
    @sequence_numbers = Hash.new
    @flood_lock = Mutex.new
    @flood_resource = ConditionVariable.new
    @flood_queue = Queue.new
    @flood_state = false
    @queue = Queue.new
    sleep(1)
    Thread.abort_on_exception = true;
  end


  def run
    Thread.new do
      Logger.info("server started")
      loop {
        Thread.start(@server_socket.accept) do |client|
          peeraddr = get_peer_address(client)
          # @clients << client
          # Logger.info("accepted connection to #{peeraddr}")
          receive_message(client)
          client.close
        end
      }
    end
  end

  def do_routing_update
    @routing_update_thread = Thread.new do
      loop {
        # @flood_mutex.synchronize {
        #   # @flood_resource.wait(@flood_mutex)
        #   if @flood_state == false
        #     @flood_state = true   # started flooding
        #     # initiate_flooding
        #     puts "set to : #{@flood_state}"
        #     STDOUT.flush
        #   end
        #   # @flood_resource.broadcast
        # }
        #---------------------------------------------------
        # read costs file
        #---------------------------------------------------
        costs_map, hostname_ip_map = Utility.read_link_costs(@weight_file)
        neighbors = costs_map[@node_name]

        #---------------------------------------------------
        # check link state and construct packet
        #---------------------------------------------------
        link_state_packet = {}
        neighbors.each do |name, array|
          ip, cost = array
          begin
            s = Client.new(ip, 7000)
            s.close
            link_state_packet[name] = cost
          rescue Exception => e
            Logger.error("#{e} #{name}")
          end
        end
        #---------------------------------------------------
        # send packet to available neighbors
        #---------------------------------------------------
        flood_msg = MessageBuilder.create_flood_message(@node_name, link_state_packet)
        link_state_packet.each do |name, cost|
          ip, _ = neighbors[name]
          send_message(name, ip, flood_msg)
        end

        sleep(@update_interval)
      }
    end
  end

  def initiate_flooding
    Logger.info("updating routing table")

    # TODO: add lock
    @link_costs_map, _ = Utility.read_link_costs(@weight_file)
    @neighbors = @link_costs_map[node_name]
    flood_message = MessageBuilder.create_flood_message(@node_name, @neighbors)
    neighbor_names = @neighbors.clone

    for neighbor in neighbor_names.each do
       send_message(neighbor[0], flood_message)         
    end
  end

  def do_forced_link_state
    Thread.kill(@routing_update_thread)
    do_routing_update()
  end


  def receive_message(client_node)
    puts "handling message..."
    STDOUT.flush
    msg = client_node.read
    puts msg
    STDOUT.flush
    # parsed_msg = JSON.parse(msg)
    # header = parsed_msg['HEADER']

    # if header['TYPE'] == 'FLOOD'
    #   @flood_queue << parsed_msg
    # else
    #   @queue << parsed_msg
    # end
    
  end

  def handle_flood_messages
    Thread.new do
      loop {

        parsed_msg = @flood_queue.pop
        puts @flood_state
        STDOUT.flush
        
        sender = parsed_msg['HEADER']['SENDER']
        seq = parsed_msg['HEADER']['SEQUENCE']

        @flood_mutex.synchronize {
          # @flood_resource.wait(@flood_mutex)
          if @flood_state == false   # flooding has not started
            # send one flood message
            @flood_state = true
            initiate_flooding
            
          end
          # @flood_resource.broadcast
        }

        # puts "#{sender} > #{seq}"
        neighbor_names = @neighbors.clone

        if @sequence_numbers.has_key?(sender)
          # compare
          if @sequence_numbers[sender] < seq
            # update
            @sequence_numbers[sender] = seq
            # send messages
            for neighbor in neighbor_names.each do
              if neighbor[0] != sender
                send_message(neighbor[0],parsed_msg.to_json)    
              end     
            end
          end

        else
          # add it
          # update
          @sequence_numbers[sender] = seq
          # send messages
          for neighbor in neighbor_names.each do
            if neighbor[0] != sender
              send_message(neighbor[0],parsed_msg.to_json)    
            end     
          end

        end

        if @sequence_numbers.length == 3
          puts @sequence_numbers 
          STDOUT.flush
          @flood_mutex.synchronize {
            # @flood_resource.wait(@flood_mutex)
            @flood_state = false
            # @flood_resource.broadcast
          }
          @sequence_numbers = Hash.new
        end
      }
    end
  end

  def send_message(server_name, server_ip, msg)
    Thread.new do
      # 1. Check if msg is for this server
      # 2. Check if node exists in forwarding table
      # 3. If not, the node is unreachable (print error)
      # ===========================server_ip = server_node[1]  if array
      # name, server_ip = server_node
      # server_ip = get_address(server_node)
      # if server_ip == 'unreachable'
      #   puts 'SENDMSG ERROR: HOST UNREACHABLE'
      #   STDOUT.flush
      # else

        begin
          s = Client.new(server_ip, 7000)
          s.send(msg)
          s.close
        rescue Exception => e
          Logger.error("#{e} #{server_name} => #{server_ip}")
        end
      # end

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

  def check_link_state
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

  attr_reader :node_name, :server_socket
end