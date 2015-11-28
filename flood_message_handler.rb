class FloodMessageHandler

	def self.handle(parsed_msg)
		LinkStateManager.enqueue(parsed_msg)
	end

end