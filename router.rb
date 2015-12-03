require 'thread'
require 'set'
require_relative 'graph'
require_relative 'link_state_manager'

class Router

	@@semaphore = Mutex.new
	@@fwd_table = nil

	def self.forward(parsed_msg)
		@@semaphore.synchronize {

			dst = parsed_msg['HEADER']['TARGET']
			src, next_hop = @@fwd_table[dst]
			next_hop_ip = LinkStateManager.get_ip(src, next_hop)
			next_hop_port = $__node_ports[next_hop]
			msg = parsed_msg.to_json
			begin
				Client.send(msg, next_hop_ip, next_hop_port)
			rescue Exception => e 
				# TODO
				Logger.error("#{e} #{next_hop_ip} #{next_hop_port}")
			end
		}

	end

	def self.forward_to_neighbors(parsed_msg)
		@@semaphore.synchronize {
			
			neighbor_set = Set.new

			@@fwd_table.each do |k,v|
				neighbor_set.add(v[1])
			end

			#arr = []


			neighbor_set.each do |neighbor|
				# copy = {}
				# copy = parsed_msg.clone
				parsed_msg["HEADER"]["TARGET"] = neighbor
				# arr.push(copy)
				# puts copy


				dst = parsed_msg['HEADER']['TARGET']
				src, next_hop = @@fwd_table[dst]
				next_hop_ip = LinkStateManager.get_ip(src, next_hop)
				next_hop_port = $__node_ports[next_hop]
				msg = parsed_msg.to_json
				begin
					Client.send(msg, next_hop_ip, next_hop_port)
				rescue Exception => e 
					# TODO
					Logger.error("#{e} #{next_hop_ip} #{next_hop_port}")
				end

			end
			neighbor_set.length
			
		}
	end

	def self.update(fwd_table)
		@@semaphore.synchronize {
			@@fwd_table = fwd_table
		}
	end
end
