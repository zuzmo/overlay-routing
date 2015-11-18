

require_relative './utility.rb'
require 'thread'

@debug_mode = true                                             #if true will print out debug messages
@weights_file_name
@update_interval
@port = 7000
@hook_pid

def main
				
	 config_options = Utility.read_config("./s1/config")
	 @update_interval = config_options["updateInterval"]
	 @weights_file_name = config_options["weightFile"]
     
     @hook_pid = Thread.new{listen_for_hook}                    #initializes he thread that listens for hooks from stdin     
     start_heartbeat()                                          #keeps meain thread alive

end


def listen_for_hook
	loop do	
		user_input = gets.chomp                               #blocks while waiting for user input
		
		case user_input
		when /^DUMPSTABLE\s[\w\d\.]*/
			file_name = user_input.split(" ")[1]
			#todo
		when /^FORCEUPDATE/
			#todo
		when /^CHECKSTABLE/
			#todo
		else
			puts "try again"
		end
	end
end


def start_heartbeat
	loop do
		sleep 1
	end
end

def dbg(message)
	if @debug_mode == true
		puts message
	end
end


main                   #starts the main method


