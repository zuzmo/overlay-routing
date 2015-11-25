require 'json'

class MessageBuilder

	@@flood_msg_seq =  0
	def self.create_flood_message(sender, payload)
		@@flood_msg_seq += 1
		flood_message = {
				"HEADER" =>
						{"TYPE" => "FLOOD",
						 "SENDER" => "#{sender}",
						 "SEQUENCE" => @@flood_msg_seq
						 },
				"PAYLOAD" => "#{payload}"
		}

		flood_message.to_json
	end

	def self.create_send_message(sender, target, sequence, ack)
		send_message = {
				"HEADER" =>
						{"TYPE" => "SNDMSG",
						 "SENDER" => "#{sender}",
						 "TARGET" => "#{target}",
						 "SEQUENCE" => "#{sequence}",
						 "ACK" => "#{ack}"
						}
		}

		send_message.to_json
	end

	def self.create_ping_message(sender, target, sequence, ack)
		ping_message = {
				"HEADER" =>
						{"TYPE" => "PING",
						 "SENDER" => "#{sender}",
						 "TARGET" => "#{target}",
						 "SEQUENCE" => "#{sequence}",
						 "ACK" => "#{ack}"
						}
		}

		ping_message.to_json
	end


end
