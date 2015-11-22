require 'socket'

require_relative 'utility'
require_relative 'server'
require_relative 'debug'
require_relative 'logger'


#==============================================================================
# 0. Read config and nodename as args
#==============================================================================
if ARGV.length != 2
  puts "Invalid number of arguments."
  puts "Usage: ruby main.rb config <node_name>"
  exit(1)
end

$config_file = ARGV[0]
$node_name = ARGV[1]
Logger.init($node_name)
puts "#{$config_file} #{$node_name}"

#==============================================================================
# 1. Read config files (config and weights.csv)
#==============================================================================
config_options = Utility.read_config($config_file)
$update_interval = config_options['updateInterval']
$weight_file = config_options['weightFile']

$neighbors_map, $link_cost_map = Utility.read_link_costs('weights.csv')
puts "#{$update_interval}"
puts "#{$weight_file}"
puts "#{$neighbors_map} #{$link_cost_map}"

#==============================================================================
# 2. Start server to accept connections and
# attempt to connect to neighbors every 5 sec.)
# Start link state every updateInterval

#==============================================================================
neighbors = $neighbors_map[$node_name]
# puts "#{neighbors_to_connect}"
# starts server in an separate thread
server = Server.new($node_name, 7000, neighbors)
server.run
server.monitor_link_state

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
      #todo
    when /^CHECKSTABLE/
      #todo
    when /^shutdown/
      server.shutdown
      exit(1)
    when /^debug/
      Debug.dump(server)
    else
      puts "try again"
    end
end





