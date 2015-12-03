require 'json'

require_relative 'message_builder'
require_relative 'utility'

class FtpHandler

	def self.handle_from_console(dst, file, file_path)
		if dst == $__node_name
			puts "Invalid node: #{dst}"
		else
			#read file
			payload = Utility.read_bytes(file)
			print payload
			msg = MessageBuilder.create_ftp_message($__node_name, dst, payload)
			forward(JSON.parse(msg))
		end
	end

	def self.handle_received(parsed_msg)
		if parsed_msg['HEADER']['TARGET'] == $__node_name
			puts "#{parsed_msg['PAYLOAD']}" # TODO
		else
			forward(parsed_msg)
		end
	end

	def self.forward(parsed_msg)
		Router.forward(parsed_msg)
	end

end