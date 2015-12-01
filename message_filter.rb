require 'json'
require_relative 'hello_message_handler'
require_relative 'flood_message_handler'
require_relative 'send_message_handler'
require_relative 'traceroute_message_handler'

#==========================================================
# Filter parses the recived messages and passes them to 
# their message handler
#==========================================================
class MessageFilter

	def self.handle(parsed_msg)

		type = parsed_msg['HEADER']['TYPE']
		
		if 		type 	== 'HELLO'
			HelloMessageHandler.handle(parsed_msg)
		elsif 	type 	== 'FLOOD'
			FloodMessageHandler.handle(parsed_msg)
		elsif 	type 	== 'SENDMSG'
			SendMessageHandler.handle(parsed_msg)
		elsif type == 'TRACEROUTE'
			TracerouteMessageHandler.handle(parsed_msg)
		end
	end

end