

require_relative './utility.rb'
require_relative './clock.rb'
require_relative './message_builder.rb'
require_relative './server.rb'
require 'thread'

@debug_mode = true 


	# =========================================================================
	# Starts the program.
	# =========================================================================
	def main
		 dbg("entering main()")
		 read_config_file()
	     listen_for_hook()
	     start_server()
	     start_flood_timer()
	     dbg("done main()")
	end


	def start_server
		dbg("entering start_server()")
		begin 
			@server = Server.new($node_name, 7000, @hostname_ip_map)
			@server.run
		rescue Exception => e
			dbg("error in start_server(). Failed to start server")
		end
		dbg("exiting start_server()")
	end


	def start_flood_timer	
		dbg("entering start_flood_timer()")
		@flood_timer_pid = Thread.new{
			loop do	
				#sleep @update_interval.to_i
				sleep 3
				start_flood()
			end
		}
		dbg("exiting start_flood_timer()")
	end


	def start_flood
		dbg("entering start_flood()")
		#f = packet_creator.create_flood_packet
		flood_message = Messages.create_flood_message("a",443)
		#for each neighbor n
		for neighbor in @hostname_ip_map[@node_name].each do					
 			
 			name = neighbor[0]

 			# client.new.connect(n).send_flood_packet(f)
		    #client.send
		    #client.close
			 @server.send_message(name,flood_message)					
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

		dbg("exiting start_flood()")
	end


	# =========================================================================
	# Reads the config file and sets up constants.
	# =========================================================================	
	def read_config_file
		 dbg("entering read_config_file()")
		 config_options = Utility.read_config("./s1/#{@config_file_name}")
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
		dbg("exiting listen_for_hook()")
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

if ARGV.length != 2
  puts "Invalid number of arguments."
  puts "Usage: ruby main.rb config <node_name>"
  exit(1)
end

@config_file_name = ARGV[0]
@node_name = ARGV[1]
master = Thread.new{main}
start_heartbeat()       


