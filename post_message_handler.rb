
require_relative 'logger'

class PostMessageHandler

	@@reply_to = ""
	@@heard_from = []
	@@counter = 0

	def self.handle_from_console(id,msg)

		refresh_data()

		if $__subscriptions[id] == nil
			Logger.error "the subscription id doesn't exist"
			return
		end

		arr = $__subscriptions[id].clone


		if arr == nil || arr.size == 0
			Logger.error "sent to nobody"
			return
		end


		next_node,arr = dest_with_least_cost(arr)

		message = MessageBuilder.create_post_message(
			$__node_name,$__node_name,next_node,false,id,arr,msg)

		@@sent_to = next_node
		@@reply_to = ""
		@@heard_from = []
		@@counter = 0
		forward(JSON.parse(message))
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
			
			if parsed_message["HEADER"]["ACK"] == "false"
				parsed_message["HEADER"]["RCVD"].push($__node_name)
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
			Logger.info "POST FAILURE: #{uniq_seq} NO RESPONSE IN #{$__ping_timeout}" 
		end

	end

	def self.print_results(parsed_message)

		
		arr = parsed_message["HEADER"]["RCVD"]
		uniq_seq = parsed_message["HEADER"]["UNIQUE_SEQ"]
		
		if arr.size < $__subscriptions[uniq_seq].size
			Logger.print "POST FAILURE: #{uniq_seq} NODES "

				$__subscriptions[uniq_seq].each do |node|
					if arr.include?(node) == false
						Logger.print "#{node} "
					end
				end
			Logger.info "FAILED TO RECEIVE MESSAGE"
		else
			Logger.info "POST #{uniq_seq} DELIVERED TO #{arr.length}"
		end

	end

	def self.print_successful_reply(parsed_message)
		msg = parsed_message["HEADER"]["MSG"]
		originator = parsed_message["HEADER"]["ORIGINATOR"]
 		Logger.info "SNDMSG: #{originator} --> #{msg}"
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


	def self.dest_with_least_cost(marr)
 		
 		arr = marr.clone
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