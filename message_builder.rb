require 'json'

class MessageBuilder

	def self.create_hello_message(sender)
		{
			'HEADER' 	=> {	'TYPE' => 'HELLO' },
			'PAYLOAD' 	=> "#{sender}"
		}.to_json
	end


	@@flood_msg_seq =  -1
	def self.create_flood_message(sender, payload)
		@@flood_msg_seq += 1
		{
			'HEADER' 	=> {	'TYPE' 		=> 'FLOOD',
								'SENDER' 	=> "#{sender}",
								'FORWARDER' => "#{sender}",
								'SEQUENCE' 	=> @@flood_msg_seq,
								'AGE'		=> 0
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

	@@ping_msg_seq = -1
	def self.create_ping_message(sender, target, num_pings, time)
		@@ping_msg_seq += 1
		{
				'HEADER' =>
						{'TYPE' => 'PING',
						 'SENDER' => sender,
						 'TARGET' => target,
						 'SEQUENCE' => @@ping_msg_seq,
						 'ACK' => 0,
						 'NUM_PINGS' => num_pings,
						 'TIME_SENT' => "#{time}"

						},
				'PAYLOAD' => 'test'
		}.to_json

	end

	@@traceroute_msg_seq =  -1
	def self.create_traceroute_message(sender,target,time_sent,ack)
		@@flood_msg_seq +=  1
		traceroute_message = {
				"HEADER" =>
						{"TYPE" => "TRACEROUTE",
						 "SENDER" => "#{sender}",
						 "TARGET" => "#{target}",
						 "SEQUENCE" => "#{@@flood_msg_seq}",
						 "TIME_SENT" => "#{time_sent}",
						 "HOP" => 0,
						 "TRACEROUTE" => {"#{sender}" => {"TIME" => "0.0","HOP" => "0"}},
						 "ACK" => "#{ack}"
						},
				"PAYLOAD" => "test"
		}
		traceroute_message.to_json
	end	

	@@ftp_msg_seq = 0
	def self.create_ftp_message(sender, target, fname, fpath, payload, ack, time)
		@@ftp_msg_seq += 1
		{
			'HEADER' => { 	'TYPE' 		=> 'FTP',
							'SENDER' 	=> sender,
							'TARGET' 	=> target,
							'FILE'		=> fname,
							'PATH'		=> fpath,
							'SEQUENCE' 	=> @@ftp_msg_seq,
							'TIME'		=> time,
							'ACK' 		=> ack
						},
			'PAYLOAD' => "#{payload}"
		}.to_json
	end

	@@clocksync_msg_seq = 0
	def self.create_clocksync_message(sender,target,time_sent,ack)
		@@clocksync_msg_seq +=  1
		clocksync_message = {
				"HEADER" =>
						{"TYPE" => "CLOCKSYNC",
						 "SENDER" => "#{sender}",
						 "TARGET" => "#{target}",
						 "SEQUENCE" => "#{@@clocksync_msg_seq}",
						 "TIME_SENT" => "#{time_sent}",
						 "ACK" => "#{ack}"
						},
				"PAYLOAD" => "test"
		}
		clocksync_message.to_json
	end

end
