require 'thread'

require_relative 'link_state_manager'

class Router

	@@semaphore = Mutex.new
	@@fwd_table = nil

	def self.forward(parsed_msg)
		@@semaphore.synchronize {
			# puts "#{@@fwd_table}"
			# puts "parsed_msg: #{parsed_msg}"
			puts parsed_msg.class
			dst = parsed_msg['HEADER']['TARGET']
			src, next_hop = @@fwd_table[dst]

			puts "src: #{src}, next_hop: #{next_hop}"

			next_hop_ip = LinkStateManager.get_ip(src, next_hop)
			next_hop_port = $__node_ports[next_hop]
			msg = parsed_msg.to_json
			# puts "triple: #{next_hop_ip}, #{next_hop_port}, #{msg}"
			begin
				Client.send(msg, next_hop_ip, next_hop_port)
			rescue Exception => e 
				# TODO
				puts "failed"
			end
		}

	end

	def self.update(fwd_table)
		@@semaphore.synchronize {
			@@fwd_table = fwd_table
		}
	end
end
