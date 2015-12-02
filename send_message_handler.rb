require_relative 'fragmenter'
require_relative 'message_builder'

class SendMessageHandler

	def self.handle_from_console(dst, payload)
		if dst == $__node_name
			puts "#{payload}"
		else
			# fragment message into packets
			msg = MessageBuilder.create_send_message($__node_name, dst, payload)
			forward(JSON.parse(msg))
		end
	end

	def self.handle_received(parsed_msg)
		if parsed_msg['HEADER']['TARGET'] == $__node_name
			puts "#{parsed_msg['PAYLOAD']}"
		else
			forward(parsed_msg)
		end
	end

	def self.forward(parsed_msg)
		Router.forward(parsed_msg)
	end

end