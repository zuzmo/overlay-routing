

require_relative './utility.rb'
require_relative './clock.rb'
require_relative './message_builder.rb'
require_relative './client.rb'
require 'thread'

@debug_mode = true 


	# =========================================================================
	# Starts the program.
	# =========================================================================
	def main
		 dbg("entering main()")
		 read_config_file()
	     listen_for_hook()
	     start_flood_timer()
	     dbg("done main()")
	end



	def start_flood_timer	
		@flood_timer_pid = Thread.new{
			loop do	
				#sleep @update_interval.to_i
				sleep 3
				start_flood()
			end
		}
	end


	def start_flood

		#f = packet_creator.create_flood_packet
		json = Messages.create_flood_message("a",443)
		#for each neighbor n
		puts @hostname_ip_map
		for n in @hostname_ip_map.keys.each do		
		#   client.new.connect(n).send_flood_packet(f)

			

		#   c.close

		end
		#server.listen for packets p
		#    p.check sender
		#      if sender.sequence > sender.curr_sequence 
		#          store. for all neighbors n
		#             client.new.connect(n).send_flood_packet(p)
		#             c.close       
		#      else ignore
		# if number of packets stored == num_of_nodes 
		#     send all packets to graph to be processed
		#     update forwarding table
		# else
		#     wait or time_out
	end


	# =========================================================================
	# Reads the config file and sets up constants.
	# =========================================================================	
	def read_config_file
		 dbg("entering read_config_file()")
		 config_options = Utility.read_config("./s1/config")
		 @update_interval = config_options["updateInterval"]
		 @weights_file_name = config_options["weightFile"]
		 @hostname_ip_map, @link_cost_map = Utility.read_link_costs("./s1/#{@weights_file_name}")
		 dbg("done read_config_file()")
	end



	# =========================================================================
	# Listens and interprets commands given to stdin.
	# =========================================================================
	def listen_for_hook
		dbg("entering listen_for_hook()")
		@hook_pid = Thread.new{
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
		}
	end


	# =========================================================================
	# Keeps the main thread from dying. Updates the clock.
	# =========================================================================
	def start_heartbeat
		dbg("entering start_heartbeat")
		@clock = Clock.new
		loop do
			sleep 1
			@clock.tick(1)
			dbg @clock.get_time
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


master = Thread.new{main}
start_heartbeat()       


