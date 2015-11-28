require 'json'

class MessageBuilder

	def self.create_hello_message(sender)
		{
			'HEADER' 	=> {	'TYPE' => 'HELLO' },
			'PAYLOAD' 	=> "#{sender}"
		}.to_json
	end


	@@flood_msg_seq =  0
	def self.create_flood_message(sender, payload)
		@@flood_msg_seq += 1
		{
			'HEADER' 	=> {	'TYPE' 		=> 'FLOOD',
								'SENDER' 	=> "#{sender}",
								'SEQUENCE' 	=> @@flood_msg_seq
							},
			'PAYLOAD' 	=> "#{payload}"
		}.to_json
	end


	@@send_msg_seq =  0
	def self.create_send_message(sender, target, payload)
		@@send_msg_seq += 1
		{
			'HEADER' => { 	'TYPE' 		=> 'SNDMSG',
							'SENDER' 	=> sender,
							'TARGET' 	=> target,
							'SEQUENCE' 	=> @@send_msg_seq,
							'ACK' 		=> 0
						},
			'PAYLOAD' => payload
		}.to_json
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
