require 'json'

class MessagesBuilder

	@@sequence_number = 1


	def get_Sequence_number
		@@sequence_number
	end


	def self.create_flood_message(sender)
		flood_message = {
				"HEADER" =>
						{"TYPE" => "FLOOD",
						 "SENDER" => "#{sender}",
						 "SEQUENCE" => @@sequence_number
			  }
		}

		@@sequence_number += 1
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
