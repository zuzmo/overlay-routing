require 'thread'

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

	def self.update(fwd_table)
		@@semaphore.synchronize {
			@@fwd_table = fwd_table
		}
	end
end
