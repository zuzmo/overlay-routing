require 'socket'

require_relative 'debug'
require_relative 'clock'
require_relative 'link_state_manager'
require_relative 'logger'
require_relative 'send_message_handler'
require_relative 'server'
require_relative 'utility'

#==========================================================
# 0. Read args from stdin
#==========================================================
if ARGV.length != 2
  puts "Invalid number of arguments."
  puts "Usage: ruby main.rb config <node_name>"
  exit(1)
end

config_file		= ARGV[0]
$__node_name 	= ARGV[1]

# Logger.init($node_name)
Thread.abort_on_exception = true;

#==========================================================
# 1. Read config files (config, weights.csv, and nodes.txt)
# and build neighbors map
#==========================================================
config_options 		= Utility.read_config(config_file)

$__update_interval 	= config_options['updateInterval'].to_i
$__weight_file 		= config_options['weightFile']
$__nodes_file		= config_options['nodes']
$__max_packet_size 	= config_options['maxPacketSize'].to_i
$__ping_timeout		= config_options['pingTimeout']
$__node_ports		= Utility.read_ports($__nodes_file)

#==========================================================
# 2. Run server to accept connections
#==========================================================
$__port = $__node_ports[$__node_name]
Thread.new {Server.run($__node_name, $__port)}

#==========================================================
# 2. Broadcast link state every updateInterval seconds
#==========================================================
Thread.new do
	sleep(1) # wait for other servers to start up
	loop {
		LinkStateManager.broadcast_link_state
		sleep($__update_interval)
	}
end
sleep(2) # wait to initialize shared resources 

#==========================================================
# 3. Handle flood messages
#==========================================================
Thread.new {LinkStateManager.handle_flooding}

#==========================================================
# 4. Read commands from stdin
#==========================================================
$_time_now
def start_heartbeat

		# dbg("entering start_heartbeat")

		@heartbeat_pid = Thread.new{
			@clock = Clock.new
			loop do
				sleep 1
				@clock.tick(1)
				$_time_now = @clock.get_time
		    	# dbg @clock.get_time
			end
		}

end
start_heartbeat
loop do 

    user_input = STDIN.gets.chomp
    
    case user_input
    when /^DUMPTABLE\s[\w\d\.]*/
      file_name = user_input.split(" ")[1]
      #todo
    when /^FORCEUPDATE/
    	LinkStateManager.broadcast_link_state
    when /^CHECKSTABLE/
    	LinkStateManager.check_stable?
    when /^SHUTDOWN/
    	exit(1)
    when /^debug/
      Debug.dump(server)
    when /^SNDMSG\s+(.+)\s+"(.+)"/
      dst, msg = $1, $2
      SendMessageHandler.handle_from_console(dst, msg)
  	when /^TRACEROUTE\s[\w\d\.]*/
				dest = user_input.split(" ")[1]
				m = MessageBuilder.create_traceroute_message(
				$__node_name,dest,443,$_time_now,false)
				# graph = Graph.new($_linked_cost_map)
				# table = graph.forwarding_table($_node_name)
				# next_hop = table[dest][1]
				# ip = $_hostname_ip_map["#{$_node_name}"][next_hop]
				# Client.send(m, ip, 7000)
				Router.forward(JSON.parse(m))
    else
      puts "try again"
    end
end





