require 'json'
require 'thread'

require_relative 'client'
require_relative 'graph'
require_relative 'logger'
require_relative 'message_builder'
require_relative 'router'
require_relative 'utility'


class LinkStateManager

	INFINITY = 'Infinity'
	@@ip_map = nil
	@@graph = nil
	@@graph_lock = Mutex.new
	@@ip_map = nil
	@@interface_map = nil

	def self.broadcast_link_state
		#---------------------------------------------------
        # read costs file
        #---------------------------------------------------
        cost_map, @@ip_map, @@interface_map = Utility.read_link_costs($__weight_file)
        @@neighbors_ip_map = @@ip_map[$__node_name]

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
        # send packet to online neighbors
        #---------------------------------------------------
        flood_msg = MessageBuilder.create_flood_message($__node_name, link_state_message.to_json)
        begin
        	Client.send_local(flood_msg, $__node_ports[$__node_name])
        rescue Exception => e
            # Logger.error("#{e} local")
        end
	end


	@@parsed_flood_mgs = Queue.new
	def self.handle_flooding
		link_state_buffer = {} 	# keeps track of received messages
		link_state_table = {}
		loop {
			parsed_flood_msg = @@parsed_flood_mgs.pop	# block waiting for flood message

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
						if cost == INFINITY
							link_state_table.delete(dst) # not sure if this is needed
						end
					end
					# and forward
					parsed_flood_msg['HEADER']['FORWARDER'] = $__node_name
					parsed_flood_msg['HEADER']['AGE'] = age + 1
					@@neighbors_ip_map.each do |neighbor, ip|
						if fwd != neighbor and src != neighbor
							ip = @@neighbors_ip_map[neighbor]
							port = $__node_ports[neighbor]
							begin
								Client.send(parsed_flood_msg.to_json, ip, port)
							rescue Exception => e
								# Logger.error("#{e} #{neighbor}")
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
							if cost == INFINITY
								link_state_table.delete(dst) # not sure if this is needed
							end
						end
						# and forward
						parsed_flood_msg['HEADER']['FORWARDER'] = $__node_name
						parsed_flood_msg['HEADER']['AGE'] = age
						@@neighbors_ip_map.each do |neighbor, ip|
							if fwd != neighbor and src != neighbor
								ip = @@neighbors_ip_map[neighbor]
								port = $__node_ports[neighbor]
								begin
									Client.send(parsed_flood_msg.to_json, ip, port)
								rescue Exception => e
									# Logger.error("#{e} #{neighbor}")
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
					if cost == INFINITY
						link_state_table.delete(dst) # not sure if this is needed
					end
				end
				# and forward
				parsed_flood_msg['HEADER']['FORWARDER'] = $__node_name
				parsed_flood_msg['HEADER']['AGE'] = age + 1
				@@neighbors_ip_map.each do |neighbor, ip|
					if fwd != neighbor and src != neighbor
						ip = @@neighbors_ip_map[neighbor]
						port = $__node_ports[neighbor]
						begin
							Client.send(parsed_flood_msg.to_json, ip, port)
						rescue Exception => e
							# Logger.error("#{e} #{neighbor}")
						end
					end
				end

			end

			# build graph by using linkstate table
			if @@parsed_flood_mgs.empty?
				@@graph_lock.synchronize {
					@@graph = Graph.new(link_state_table)
					fwd_table = @@graph.forwarding_table($__node_name)
					Router.update(fwd_table)
				}
			end
			
		}
	end

	def self.enqueue(parsed_flood_msg)
		@@parsed_flood_mgs << parsed_flood_msg
	end

	def self.check_stable?
		@@parsed_flood_mgs.empty?
	end

	def self.get_ip(src, dst)
		@@ip_map[src][dst]
	end

	def self.get_table_data
		table = @@graph.forwarding_table($__node_name)

		data = ''
		table.keys.each do |dest_node|
			path, cost = @@graph.src_to_dest($__node_name, dest_node)
			# Printing DUMPTABLE
			next_hop_node = table[dest_node][1]
			next_hop_ip = @@ip_map[$__node_name][next_hop_node]

			for src_ip in @@interface_map[$__node_name]
				for dest_ip in @@interface_map[dest_node]
					data << "#{src_ip},#{dest_ip},#{next_hop_ip},#{cost}\n"
				end
			end
		end

		data
	end
end