require 'json'

#==========================================================
# Fragmenter converts a message into packets depending on 
# the maxPacketSize option in the config file.
#==========================================================

class Defragmenter

	def self.defragment(packet_arr)
		payload = ''
		msg = JSON.parse(packet_arr[0])
		packet_arr.each do |packet|
			parsed_packet = JSON.parse(packet)
			chunk = parsed_packet['PAYLOAD']
			payload << chunk
		end
		msg['PAYLOAD'] = payload
		msg
	end

end