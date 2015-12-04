require 'json'
require 'time'

class ClocksyncMessageHandler

	@@num_sent = 0
	@@replies = []

	def self.handle_from_console()
		@@num_sent = 0
		@@replies = []
		m = MessageBuilder.create_clocksync_message($__node_name,"",$_time_now,false)
		@@num_sent = Router.forward_to_neighbors(JSON.parse(m))
	end	


	def self.handle(parsed_msg)
		ack = parsed_msg["HEADER"]["ACK"]
		sender = parsed_msg["HEADER"]["SENDER"]

		if ack == "false"	
			puts "CLOCKSYNC from #{sender}: TIME = #{$_clock.get_formatted_time}"
			reply_to_sender(parsed_msg)
		else
			@@replies.push(parsed_msg)
			if @@replies.size == @@num_sent
				sync()
			end			
		end
	end

	def self.reply_to_sender(msg)
		original_sender = msg["HEADER"]["SENDER"]
		time_sent = msg["HEADER"]["TIME_SENT"]
		parsed_time = Time.parse(time_sent)
		diff = Time.parse($_time_now) - parsed_time

		msg["HEADER"]["SENDER"] = $__node_name
		msg["HEADER"]["TARGET"] = original_sender
		msg["HEADER"]["ACK"] = true
		msg["HEADER"]["DELTA"] = diff

		Router.forward_to_neighbors(msg)
 	end

 	def self.sync()
 		master = @@replies.sort_by{|k,v|k["HEADER"]["SENDER"]}.first
 		delta = master["HEADER"]["DELTA"].to_i
 		$_clock.tick(delta)
		time = Time.parse($_time_now)
		hour = format('%02d',"#{time.hour}")
		min = format('%02d',"#{time.min}")
		sec = format('%02d',"#{time.sec}")

 		puts "CLOCKSYNC:TIME=#{$_clock.get_formatted_time} DELTA=#{delta}"
 	end

end