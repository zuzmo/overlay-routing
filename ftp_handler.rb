require 'json'

require_relative 'message_builder'
require_relative 'utility'

class FtpHandler

	def self.handle_from_console(dst, fname, fpath)
		if dst == $__node_name
			puts "Invalid node: #{dst}"
		else
			#read file
			payload = Utility.read_bytes(fname)
			print payload
			msg = MessageBuilder.create_ftp_message($__node_name, dst, fname, fpath, payload, 0, $_time_now)
			forward(JSON.parse(msg))
		end
	end

	def self.handle_received(parsed_msg)
		if parsed_msg['HEADER']['TARGET'] == $__node_name
			seq_num = ['HEADER']['SEQUENCE'] + 1
			# prepare ack msg
			ack_msg = MessageBuilder.create_ftp_message($_node_name, dst, '', '', '', seq, $_time_now)
			# save to disk
			fname = parsed_msg['HEADER']['FILE']
			fpath = parsed_msg['HEADER']['PATH']
			payload = parsed_msg['PAYLOAD']
			arr = Fragmenter.chunkify(payload, 2)
			bytes = arr.pack('H2'*arr.size)
			file_path = fpath + "/"+ fname
			Utility.write_bytes(file_path, bytes)
			# send ack
			forward(ack_msg)
		else
			forward(parsed_msg)
		end
	end

	def self.handle_ack(parsed_msg)
		puts "ack: #{parsed_msg}"

	end

	def self.forward(parsed_msg)
		Router.forward(parsed_msg)
	end

end