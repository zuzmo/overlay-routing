require 'json'

require_relative 'client'
require_relative 'graph'
require_relative 'logger'
require_relative 'message_builder'
require_relative 'utility'


class LinkStateManager

	INFINITY = 'Infinity'
	@@neighbors_ip_map = nil
	@@stable = 1

	def self.broadcast_link_state
		@@stable = 0
		#---------------------------------------------------
        # read costs file
        #---------------------------------------------------
        cost_map, ip_map, _ = Utility.read_link_costs($__weight_file)
        @@neighbors_ip_map = ip_map[$__node_name]

        neighbors_cost_map = cost_map[$__node_name]
        
        #---------------------------------------------------
        # check link-state and construct link-state message
        #---------------------------------------------------
        link_state_message = {}
        neighbors_cost_map.each do |neighbor, cost|
          ip = @@neighbors_ip_map[neighbor]
          port = $__node_ports[neighbor]
          hello_msg = MessageBuilder.create_hello_message($__node_name)
          begin
            Client.send(hello_msg, ip, port)
            link_state_message[neighbor] = cost
          rescue Exception => e
            # Logger.error("#{e} #{neighbor}")
            link_state_message[neighbor] = INFINITY
          end
        end

        #---------------------------------------------------
        # send packet to alive neighbors
        #---------------------------------------------------
        flood_msg = MessageBuilder.create_flood_message($__node_name, link_state_message.to_json)
        begin
        	Client.send_local(flood_msg, $__node_ports[$__node_name])
        rescue Exception => e
            Logger.error("#{e} local")
        end
        @@stable = 1
	end


	@@parsed_flood_mgs = Queue.new
	def self.handle_flooding
		link_state_buffer = {} 	# keeps track of received messages
		link_state_table = {}
		loop {
			parsed_flood_msg = @@parsed_flood_mgs.pop	# block waiting for flood message
			@@stable = 0
			src = parsed_flood_msg['HEADER']['SENDER']
			seq = parsed_flood_msg['HEADER']['SEQUENCE']
			fwd = parsed_flood_msg['HEADER']['FORWARDER']
			age = parsed_flood_msg['HEADER']['AGE']
			if link_state_buffer.has_key?(src)
				# compare sequence number
				curr_seq = link_state_buffer[src][0]
				if seq > curr_seq
					# update sequence number
					link_state_buffer[src] = [seq, age + 1]

					# store 
					payload = parsed_flood_msg['PAYLOAD']
					parsed_payload = JSON.parse(payload)
					parsed_payload.each do |dst, cost|
						if link_state_table.has_key?(src)
							link_state_table[src][dst] = cost
						else
							link_state_table[src] = { dst => cost }
						end
						# if cost == INFINITY
						# 	link_state_table.delete(dst) # not sure if this is needed
						# end
					end
					# and forward
					parsed_flood_msg['HEADER']['FORWARDER'] = $__node_name
					parsed_flood_msg['HEADER']['AGE'] = age + 1
					@@neighbors_ip_map.each do |neighbor, ip|
						if fwd != neighbor
							ip = @@neighbors_ip_map[neighbor]
							port = $__node_ports[neighbor]
							begin
								Client.send(parsed_flood_msg.to_json, ip, port)
							rescue Exception => e
								Logger.error("#{e} #{neighbor}")
							end
						end
					end
				elsif seq < curr_seq
					# may be booting up and need its last sequence num
					curr_age = link_state_buffer[src][1]
					if age < curr_age
						# update sequence tracker
						link_state_buffer[src] = [seq, age]
						# store 
						payload = parsed_flood_msg['PAYLOAD']
						parsed_payload = JSON.parse(payload)
						parsed_payload.each do |dst, cost|
							if link_state_table.has_key?(src)
								link_state_table[src][dst] = cost
							else
								link_state_table[src] = { dst => cost }
							end
							# if cost == INFINITY
							# 	link_state_table.delete(dst) # not sure if this is needed
							# end
						end
						# and forward
						parsed_flood_msg['HEADER']['FORWARDER'] = $__node_name
						parsed_flood_msg['HEADER']['AGE'] = age
						@@neighbors_ip_map.each do |neighbor, ip|
							if fwd != neighbor
								ip = @@neighbors_ip_map[neighbor]
								port = $__node_ports[neighbor]
								begin
									Client.send(parsed_flood_msg.to_json, ip, port)
								rescue Exception => e
									Logger.error("#{e} #{neighbor}")
								end
							end
						end
					end

				end
			else
				# update sequence tracker
				link_state_buffer[src] = [seq, age + 1]
				# store 
				payload = parsed_flood_msg['PAYLOAD']
				parsed_payload = JSON.parse(payload)
				parsed_payload.each do |dst, cost|
					if link_state_table.has_key?(src)
						link_state_table[src][dst] = cost
					else
						link_state_table[src] = { dst => cost }
					end
					# if cost == INFINITY
					# 	link_state_table.delete(dst) # not sure if this is needed
					# end
				end
				# and forward
				parsed_flood_msg['HEADER']['FORWARDER'] = $__node_name
				parsed_flood_msg['HEADER']['AGE'] = age + 1
				@@neighbors_ip_map.each do |neighbor, ip|
					if fwd != neighbor
						ip = @@neighbors_ip_map[neighbor]
						port = $__node_ports[neighbor]
						begin
							Client.send(parsed_flood_msg.to_json, ip, port)
						rescue Exception => e
							Logger.error("#{e} #{neighbor}")
						end
					end
				end

			end

			# puts "link_state #{link_state_table}"
			# 1. Build graph by using linkstate table
			graph = Graph.new(link_state_table)
			# fwd_table = graph.forwarding_table("n1")
			puts "#{graph}"
			@@stable = 1
		}
	end

	def self.enqueue(parsed_flood_msg)
		@@parsed_flood_mgs << parsed_flood_msg
	end

	def self.check_stable?
		stble = 'yes'
		if @@stable == 0
			stble = 'no'
		end
		puts "#{stble}"
	end
end