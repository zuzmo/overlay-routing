require 'json'

require_relative 'utility'
require_relative 'packet_builder'

#==========================================================
# Fragmenter converts a message into packets depending on 
# the maxPacketSize option in the config file.
#==========================================================

class Fragmenter

	def self.fragment(msg)
		packet_arr = []
		parsed_msg = JSON.parse(msg)
		payload = parsed_msg['PAYLOAD']
		payload_arr = chunkify(payload, $__max_packet_size)
		payload_arr.each do |chunk|
			parsed_msg['PAYLOAD'] = chunk
			packet_arr << parsed_msg.clone.to_json
		end
		packet_arr
	end


	def self.chunkify(str, chunk_size)
		str.scan(/.{1,#{chunk_size}}/)
	end
end