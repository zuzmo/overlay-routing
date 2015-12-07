require 'json'
require_relative 'message_builder'
require_relative 'logger'

class AdvertiseMessageHandler


	@@reply_to = ""
	@@heard_from = []
	@@counter = 0

	def self.handle_from_console(id,list)

		refresh_data()

		arr = 
		arr = list.split(',')
		$__subscriptions["#{id}"] = []
		next_node,arr = dest_with_least_cost(arr)

		msg = MessageBuilder.create_advertise_message(
			$__node_name,$__node_name,next_node,false,id,arr)


		@@sent_to = next_node
		@@reply_to = ""
		@@heard_from = []
		@@counter = 0
		forward(JSON.parse(msg))
 	end

	def self.handle(parsed_message)

		refresh_data()

		if parsed_message["HEADER"]["ACK"] == "true"
			kill_timer()
		end

		arr = parsed_message["HEADER"]["NODE_LIST"]

		if parsed_message["HEADER"]["ORIGINATOR"] == $__node_name && arr.length == 0
			if @@counter == 0
				print_results(parsed_message)
				@@heard_from[@@counter] = parsed_message["HEADER"]["SENDER"]
				@@counter += 1
			else
				@@heard_from[@@counter] = parsed_message["HEADER"]["SENDER"]
				print_consistency_error(parsed_message)
				@@counter += 1
			end
		else

			parsed_message["HEADER"]["NODE_LIST"] = arr
			
			if parsed_message["HEADER"]["ACK"] == "false"
				parsed_message = add_to_list(parsed_message)
				@@reply_to = parsed_message["HEADER"]["SENDER"]
			end


			if arr.length == 0
				print_successful_reply(parsed_message)
				reply(parsed_message)
			else
				next_node,arr = dest_with_least_cost(arr)

				if reply?(next_node,parsed_message["HEADER"]["SENDER"])
					print_successful_reply(parsed_message)
					reply(parsed_message)
				else
					parsed_message = prepare_to_forward(parsed_message,next_node,arr)
					print_successful_forward(parsed_message)
					forward(parsed_message)
				end
			end

		end
		
	end

	def self.print_consistency_error(parsed_message)
		uniq_seq = parsed_message["HEADER"]["UNIQUE_SEQ"]
		Logger.info "ADVERTISE #{uniq_seq}: CONSISTENCY FAULT #{@@heard_from[0]} ?? #{@@heard_from[@@counter - 1]}"
	end

	def self.kill_timer
		Thread.kill(@@timeout_pid)
	end

	def self.timeout_timer(parsed_message)
		@@timeout_pid = Thread.new {
			sleep $__ping_timeout.to_i
			print_timout_message(parsed_message)
			handle(parsed_message)
		}
	end

	def self.print_timout_message(parsed_message)
		originator = parsed_message["HEADER"]["ORIGINATOR"]

		if $__node_name == originator
			uniq_seq = parsed_message["HEADER"]["UNIQUE_SEQ"]
			Logger.info "ADVERTISE #{uniq_seq} FAILED AFTER #{$__ping_timeout}" 
		else
			next_node = parsed_message["HEADER"]["TARGET"]
			Logger.info "ADVERTISE FAILURE: NO RESPONSE FROM #{next_node} in #{$__ping_timeout}"	
		end

	end

	def self.print_results(parsed_message)

		uniq_seq = parsed_message["HEADER"]["UNIQUE_SEQ"]
		arr = parsed_message["HEADER"]["INTEREST_LIST"]
	
		interested_list = arr.select{|k,v| v == "true"}

		print "#{interested_list.size} NODES "


		interested_list.each do |k,v|
				$__subscriptions[uniq_seq].push(k)
				print "#{k} "
		end

		Logger.info "SUBSCRIBED TO #{parsed_message["HEADER"]["UNIQUE_SEQ"]}"

	end

	def self.print_successful_forward(parsed_message)
		uniq_seq = parsed_message["HEADER"]["UNIQUE_SEQ"]
		next_node = parsed_message["HEADER"]["TARGET"]
 		Logger.info "ADVERTISE: #{uniq_seq} #{@@reply_to} --> #{next_node}"
	end

	def self.print_successful_reply(parsed_message)
		uniq_seq = parsed_message["HEADER"]["UNIQUE_SEQ"]
		prev_node = parsed_message["HEADER"]["SENDER"]
 		Logger.info "ADVERTISE: #{uniq_seq} #{prev_node} --> #{@@reply_to}"
	end

	def self.prepare_to_forward(parsed_message,next_node,arr)

		parsed_message["HEADER"]["SENDER"] = $__node_name
		parsed_message["HEADER"]["TARGET"] = next_node
		parsed_message["HEADER"]["NODE_LIST"] = arr
		parsed_message["HEADER"]["ACK"] = "false"
	
		parsed_message
	end

	#checks if the next node with the shortest path goes through the sender
	def self.reply?(target,sender)

		if @paths[target].include?(sender)
			return true
		else
			return false
		end

	end

	def self.refresh_data
		h, i, j= Utility.read_link_costs($__weight_file)
		@graph = Graph.new(h)
		@paths = @graph.src_to_all_dest($__node_name)
 	end


	def self.dest_with_least_cost(arr)
 		
 		lowest_cost = 999999
 		next_node = ""
 		hash = @paths

 		arr.each do |dest|
 			hash = hash.select {|k,v| arr.include? k }
 		end

 		hash.each do |k,v|
 			size = v.length
 			curr_cost = 0
 			(1...size).each do |i|
 				 curr_cost = curr_cost + @graph.get_cost(v[i-1],v[i])
 			end
 			if curr_cost < lowest_cost
 				lowest_cost = curr_cost
 				next_node = k
 			end
 		end

 		arr.delete(next_node)
 		
		return next_node, arr

 	end

	def self.add_to_list(parsed_message)
		random = Random.rand(1..2)
		if random == 1 #add to subscription lisr
			parsed_message["HEADER"]["INTEREST_LIST"][$__node_name] = "true"
		else
			parsed_message["HEADER"]["INTEREST_LIST"][$__node_name] = "false"
		end
		parsed_message
	end

	def self.just_forward(parsed_message)
		Router.forward(parsed_message)
	end

	def self.forward(parsed_message)

		if parsed_message["HEADER"]["ACK"] == "false"
			timeout_timer(parsed_message)
		end
		Router.forward(parsed_message)
	end

	def self.reply(parsed_message)
		parsed_message["HEADER"]["TARGET"] = @@reply_to
		parsed_message["HEADER"]["SENDER"] = $__node_name
		ack = parsed_message["HEADER"]["ACK"] = "true"
		forward(parsed_message)
	end



end