require 'time.rb'
require 'json'
require_relative 'fragmenter'
require_relative 'message_builder'
require_relative './client.rb'
require_relative './graph.rb'


class TracerouteMessageHandler	

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
				forward_message(parsed_msg,sender)
			end
		else   #below are the carrying nodes
			if  ack == "true"
				forward_message(parsed_msg,dest)
			else #first round
				n_header = modify_header(header)
				parsed_msg["HEADER"] = n_header
				forward_message(parsed_msg,dest)
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

	def self.forward_message(m,dest)
		Router.forward(m)
	end

	def self.print_table(header)
		info = header["TRACEROUTE"]
		
		info.sort_by{|k,v|v["HOP"]}.each do |node,val|
			hop = val["HOP"]
			time = val["TIME"]
			puts "#{hop} #{node} #{time}"
		end
	end

end