require_relative 'fragmenter'
require_relative 'message_builder'

class SendMessageHandler

	def self.handle_from_console(dst, payload)
		if dst == $__node_name
			puts "#{msg}"
		else
			# fragment message into packets
			msg = MessageBuilder.create_send_message($__node_name, dst, payload)
			packets_arr = Fragmenter.fragment(msg)
			# TODO: forward packets
			# puts packets_arr

		end
	end

	def self.handle(parsed_msg)
	end

end