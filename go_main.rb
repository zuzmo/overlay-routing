require 'socket'

require_relative 'debug'
require_relative 'logger'
require_relative 'server'
require_relative 'utility'

#==============================================================================
# 0. Read args from stdin
#==============================================================================
if ARGV.length != 2
  puts "Invalid number of arguments."
  puts "Usage: ruby main.rb config <node_name>"
  exit(1)
end

config_file = ARGV[0]
node_name = ARGV[1]

Logger.init(node_name)

#==============================================================================
# 1. Read config files (config and weights.csv) and build neighbors map
#==============================================================================
config_options = Utility.read_config(config_file)
update_interval = config_options['updateInterval'].to_i()
weight_file = config_options['weightFile']

# neighbors_map, link_cost_map = Utility.read_link_costs(weight_file)
# puts "#{update_interval}"
# puts "#{weight_file}"
# puts "#{neighbors_map} #{link_cost_map}"

#==============================================================================
# 2. Run server to accept connections and establish connections to 
# other servers as client
#==============================================================================
# neighbors = neighbors_map[node_name]
server = Server.new(node_name, 7000, update_interval, weight_file)		
server.run() 									# runs server in a separate thread
server.do_routing_update()

server.flood_message_handler()

#==============================================================================
# 3. 
#==============================================================================


loop do 
    user_input = STDIN.gets.chomp                               #blocks while waiting for user input
    
    case user_input
    when /^DUMPSTABLE\s[\w\d\.]*/
      file_name = user_input.split(" ")[1]
      #todo
    when /^FORCEUPDATE/
    	server.do_link_state
      #todo
    when /^CHECKSTABLE/
      #todo
    when /^shutdown/
      server.shutdown
      exit(1)
    when /^debug/
      Debug.dump(server)
    when /^send\s+(.+)\s+"(.+)"/
      node = $1
      msg = $2
      server.send_message(node, msg)
    else
      puts "try again"
    end
end





