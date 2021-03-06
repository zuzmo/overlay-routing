require 'json'

require_relative 'hello_message_handler'
require_relative 'flood_message_handler'
require_relative 'send_message_handler'
require_relative 'send_encrypted_message_handler'
require_relative 'ping_message_handler'
require_relative 'traceroute_message_handler'
require_relative 'advertise_message_handler'

#==========================================================
# Filter parses the received messages and passes them to 
# their message handlers
#==========================================================
class MessageFilter

	def self.handle(parsed_msg)

		type = parsed_msg['HEADER']['TYPE']
		
		if 		type 	== 'HELLO'
			HelloMessageHandler.handle_received(parsed_msg)
		elsif 	type 	== 'FLOOD'
			FloodMessageHandler.handle_received(parsed_msg)
		elsif 	type 	== 'SNDMSG'
			SendMessageHandler.handle_received(parsed_msg)
		elsif 	type 	== 'PING'
			PingMessageHandler.handle_received(parsed_msg)
		elsif 	type 	== 'FTP'
			if parsed_msg['HEADER']['TARGET'] == $__node_name
				if parsed_msg['HEADER']['ACK'] == 'true'
					# file sent successfully
					FtpHandler.handle_received_ack(parsed_msg)
				elsif parsed_msg['HEADER']['ACK'] == 'error'
					FtpHandler.handle_transmission_error(parsed_msg)
				else
					# save to disk and send ack
					FtpHandler.handle_im_target(parsed_msg)
				end
			else
				# forward to next destination
				FtpHandler.forward(parsed_msg)
			end
		elsif 	type 	== 'TRACEROUTE'
			TracerouteMessageHandler.handle(parsed_msg)
		elsif  	type 	== 'CLOCKSYNC'
			ClocksyncMessageHandler.handle(parsed_msg)
		elsif  	type 	== 'ADVERTISE'
			if parsed_msg["HEADER"]["TARGET"] != $__node_name
				AdvertiseMessageHandler.just_forward(parsed_msg)
			else
				AdvertiseMessageHandler.handle(parsed_msg)
			end
		elsif  	type 	== 'POST'
			if parsed_msg["HEADER"]["TARGET"] != $__node_name
				PostMessageHandler.just_forward(parsed_msg)
			else
				PostMessageHandler.handle(parsed_msg)
			end
		elsif 	type 	== 'SECMSG'
			SendEncryptedMessageHandler.handle_received(parsed_msg)
		end

	end

end