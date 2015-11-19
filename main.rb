

require_relative './utility.rb'
require_relative './clock.rb'
require 'thread'

@debug_mode = true 


	# =========================================================================
	# Starts the program.
	# =========================================================================
	def main
		 read_config_file()			
	     start_clock()
	     listen_for_hook()
	     start_heartbeat()
	end


	# =========================================================================
	# creates the clock object that will get the time from the OS 
	# and update it.
	# =========================================================================
	def start_clock
	 	 @clock = Clock.new
	end


	# =========================================================================
	# Reads the config file and sets up constants.
	# =========================================================================	
	def read_config_file
		 config_options = Utility.read_config("./s1/config")
		 @update_interval = config_options["updateInterval"]
		 @weights_file_name = config_options["weightFile"]

	end


	# =========================================================================
	# Starts the thread that will be in charge if listening for commands from 
	# stdin.
	# =========================================================================
	def start_hook_listener
	     @hook_pid = Thread.new{listen_for_hook}
	end


	# =========================================================================
	# Listens and interprets commands given to stdin.
	# =========================================================================
	def listen_for_hook
		loop do	
			user_input = gets.chomp                               #blocks while waiting for user input
		
			case user_input
			when /^DUMPTABLE\s[\w\d\.]*/
				file_name = user_input.split(" ")[1]
				dumptable(file_name)
			when /^FORCEUPDATE$/
				#todo
			when /^CHECKSTABLE$/
				#todo
			else
				puts "try again"
			end
		end
	end


	# =========================================================================
	# Keeps the main thread from dying. Updates the clock.
	# =========================================================================
	def start_heartbeat
		loop do
			sleep 1
			@clock.tick(1)
		end
	end


    # =========================================================================
	# Retreives the current forwarding table from the forwarding table object 
	# and writes it to a file.
	# Params:
	#        +file -> the destination file 
	# =========================================================================
	def dumptable(file)
		#current_table = Forwarding_table.get_current_table
		cc = "banana\n"
		Utility.write_string_to_file(file,cc)

		puts "wrote to #{file}"

	end

	# =========================================================================
	# Writes messages to stdout if the debug_mode constant is set to true.
	# Params:
	#        +message -> the message to print to console
	# =========================================================================
	def dbg(message)
		if @debug_mode == true
			puts message
		end
	end


main       


