class Debug
	def self.dump(server)
		print_identifier
		log = ""
		log << "hostname: #{server.node_name} \n"
		log << "server socket: #{server.inspect} \n"
		puts log
		print_identifier
	end

	def self.print_identifier
		puts "-----------------------------------------------------------------"
	end
end