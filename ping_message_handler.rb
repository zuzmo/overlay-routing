require 'json'
require 'time.rb'
require_relative 'fragmenter'
require_relative 'message_builder'
require_relative 'logger'

class PingMessageHandler

	def self.handle_from_console(dst, num_pings, delay)
		seq = 0
		@delay_time = delay

		if dst == $__node_name
			while num_pings > 0
				Logger.info "#{seq} #{dst} #{0.0}"
				num_pings -= 1
				seq += 1
				sleep(@delay_time)
			end

		else
			create_new_packet(seq, dst, num_pings, delay)	
		end
	end

	def self.handle_received(parsed_msg)
		seq = parsed_msg['HEADER']['SEQUENCE']
		ack = parsed_msg['HEADER']['ACK']
		sender = parsed_msg['HEADER']['TARGET']
		target =  parsed_msg['HEADER']['SENDER']

		if parsed_msg['HEADER']['TARGET'] == $__node_name
			if ack == "false"
				# Dest received a packet.
				parsed_msg['HEADER']['TARGET'] = target
				parsed_msg['HEADER']['SENDER'] = sender
				parsed_msg['HEADER']['ACK'] = "true"
				begin
					forward(parsed_msg)
				rescue Exception => e
				end
			elsif ack == "true"
				# Src received an acknowledgement.
				time_sent = Time.parse(parsed_msg['HEADER']["TIME_SENT"])
				time_diff = Time.parse($_time_now) - time_sent
				if time_diff > $__ping_timeout.to_f
					Logger.info "PING ERROR: HOST UNREACHABLE"
				else
					Logger.info "#{seq} #{target} #{time_diff}"
				end

			elsif ack == "error"
				# Dest is unreachable.
				Logger.info "PING ERROR: HOST UNREACHABLE"
				
			end
		else	

			begin
				forward(parsed_msg)
			rescue Exception => e
				if e.to_s == "unreachable node"
					parsed_msg['HEADER']['TARGET'] = target
					parsed_msg['HEADER']['SENDER'] = $__node_name
					parsed_msg['HEADER']['ACK'] = "error"
					forward(parsed_msg)
				end
			end
		end
	end


	def self.create_new_packet(seq, dst, num_pings, delay)
		while num_pings > 0
			packet = MessageBuilder.create_ping_message($__node_name, dst, seq, "false", $_time_now)
			begin
				forward(JSON.parse(packet))
			rescue Exception => e
				Logger.info "PING ERROR: HOST UNREACHABLE"
			end
			
			num_pings -= 1
			sleep(delay)
			seq += 1
		end
	end

	def self.forward(parsed_msg)
		Router.forward(parsed_msg)
	end

end
