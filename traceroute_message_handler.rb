require 'time.rb'
require 'json'
require_relative 'fragmenter'
require_relative 'message_builder'
require_relative './client.rb'


class TracerouteMessageHandler

	

	def self.handle(parsed_msg)
		puts "check 1"
		header = parsed_msg["HEADER"]
		ack = header["ACK"]
		dest = header["TARGET"]
		sender = header["SENDER"]

		if dest == $_node_name
			if ack == "true"
				puts "check 2"
				print_table(header)
			else					
				puts "check 3"	
				n_header = modify_header(header)
				n_header["ACK"] = "true"
				n_header["SENDER"] = "#{$_node_name}"
				n_header["TARGET"] = sender
				parsed_msg["HEADER"] = n_header
				forward_message(parsed_msg,sender)
			end
		else
			if  ack == "true"
				puts "check 4"
				forward_message(parsed_msg,dest)
			else
				puts "check 5"
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
		header["TRACEROUTE"]["#{$_node_name}"] = [Time.parse($_time_now) - time_sent,hop]
		header
	end

	def self.forward_message(m,dest)
		ip = $_linked_cost_map["#{$_node_name}"][dest]
		Client.send(m.to_json, ip, 7000)
	end

	def self.print_table(header)
		puts header["TRACEROUTE"]
	end




end