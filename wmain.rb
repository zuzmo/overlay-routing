require 'socket'
require 'readline'

require_relative 'clock'
require_relative 'ftp_handler'
require_relative 'hooks'
require_relative 'link_state_manager'
require_relative 'logger'
require_relative 'send_message_handler'
require_relative 'send_encrypted_message_handler'
require_relative 'ping_message_handler'
require_relative 'advertise_message_handler'
require_relative 'post_message_handler'
require_relative 'server'
require_relative 'utility'

#==========================================================
# 0. Read args from stdin
#==========================================================
if ARGV.length != 2
  Logger.error("Invalid number of arguments.")
  Logger.error("Usage: ruby main.rb config <node_name>")
  exit(1)
end

config_file		= ARGV[0]
$__node_name 	= ARGV[1]

Utility.generate_keys

#for subscription

$__subscriptions = {}
$__subscribed_to = []

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
# 4. Start thread that updates clock
#==========================================================
$_time_now
$_clock
Thread.new{
	$_clock = Clock.new
	loop do
		$_clock.tick(1)
		$_time_now = $_clock.get_time
		sleep 1
	end
}

#==========================================================
# 5. Read commands from stdin
#==========================================================
begin
	while buf = Readline.readline('', true)
    
	    case buf
	    when /^DUMPTABLE\s+(.+)/
	    	# Gonzalo
	    	fname = $1
	    	Hooks.dump_table(fname)
	    when /^FORCEUPDATE/
	    	# Gonzalo
	    	Hooks.force_update
	    when /^CHECKSTABLE/
	    	# Gonzalo
	    	Hooks.check_stable
	    when /^SHUTDOWN/
	    	# George
	    	STDOUT.flush
	    	exit(1)
	    when /^SNDMSG\s+(.+)\s+"(.+)"/
	    	# Gonzalo
		    dst, msg = $1, $2
		    SendMessageHandler.handle_from_console(dst, msg)
	  	when /^TRACEROUTE\s+(.+)/
	  		# George
			dst = $1
			TracerouteMessageHandler.handle_from_console(dst)
		when /^PING\s+(.+)\s+(\d+)\s+(\d+)/
			# Ivy
	    dst, num_pings, delay = $1, $2, $3
			PingMessageHandler.handle_from_console(dst, num_pings.to_i, delay.to_i)
		when /^FTP\s+(.+)\s+(.+)\s+(.+)/
			# Gonzalo
			dst, file, file_path = $1, $2, $3
			FtpHandler.handle_from_console(dst, file, file_path)
		when /^POSTs\s+(.+)\s+(.+)/
			niq_id, nodes = $1, $2
			# ALL
		when /^ADVERTISE\s+(\w+)\s(.+)/
			uniq_id, csv = $1, $2
			AdvertiseMessageHandler.handle_from_console(uniq_id,csv)
		when /^POST\s(\w+)\s(.+)/
			uniq_id, msg = $1, $2
			PostMessageHandler.handle_from_console(uniq_id,msg)
		when /^CLOCKSYNC/
			ClocksyncMessageHandler.handle_from_console
		when /^SECMSG\s+(.+)\s+"(.+)"/		# send encrypted message
			dst, msg = $1, $2
	    	SendEncryptedMessageHandler.handle_from_console(dst, msg)
	    else
	      Logger.error("try again")
	    end

	end
rescue Interrupt => e
	exit
end
