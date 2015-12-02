class FloodMessageHandler

	def self.handle_received(parsed_msg)
		LinkStateManager.enqueue(parsed_msg)
	end

end