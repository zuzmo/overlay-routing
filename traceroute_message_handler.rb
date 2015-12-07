require 'time.rb'
require 'json'
require_relative 'fragmenter'
require_relative 'message_builder'
require_relative './client.rb'
require_relative './graph.rb'
require_relative 'logger'
	

class TracerouteMessageHandler	

	def self.handle_from_console(dest)
		if dest == $__node_name
			Logger.info "0 #{$__node_name} 0.0"
		else
			m = MessageBuilder.create_traceroute_message(
				$__node_name,dest,$_time_now,false)
			forward_message(JSON.parse(m))
		end
	end

	def self.handle(parsed_msg)
		header = parsed_msg["HEADER"]
		ack = header["ACK"]
		dest = header["TARGET"]
		sender = header["SENDER"]

		if dest == $__node_name
			if ack == "true"
				print_table(header)
			else					
				n_header = modify_header(header)
				n_header["ACK"] = "true"
				n_header["SENDER"] = "#{$__node_name}"
				n_header["TARGET"] = sender
				parsed_msg["HEADER"] = n_header
				forward_message(parsed_msg)
			end
		else   #below are the carrying nodes
			if  ack == "true"
				forward_message(parsed_msg)
			else #first round
				n_header = modify_header(header)
				parsed_msg["HEADER"] = n_header
				forward_message(parsed_msg)
			end
		end

	end


	def self.modify_header(header)
		hop = header["HOP"].to_i + 1
		header["HOP"] = hop
		time_sent = Time.parse(header["TIME_SENT"])	
		time_diff = Time.parse($_time_now) - time_sent
		if time_diff < 0
			time_diff = 0;
		end
		header["TRACEROUTE"]["#{$__node_name}"] = 
			{"TIME" => "#{time_diff}", "HOP" => "#{hop}"}
		header
	end

	def self.forward_message(m)
		Router.forward(m)
	end

	def self.print_table(header)

		info = header["TRACEROUTE"]		

		info.sort_by{|k,v|v["HOP"]}.each do |node,val|
			hop = val["HOP"]
			time_arrived = val["TIME"]

			if time_arrived > $__ping_timeout
				Logger.info "TIMEOUT ON #{hop}"
			else
				Logger.info "#{hop} #{node} #{time_arrived}"
			end

		end
	end

end