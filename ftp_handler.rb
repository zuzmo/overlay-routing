require 'json'

require_relative 'fragmenter'
require_relative 'logger'
require_relative 'message_builder'
require_relative 'router'
require_relative 'utility'

class FtpHandler

	$__ftp_count = 0
	def self.handle_from_console(dst, fname, fpath)
		if dst == $__node_name
			Logger.error("Invalid node: #{dst}")
		else
			#read file
			payload, nbytes = Utility.read_bytes(fname)
			msg = MessageBuilder.create_ftp_message($__node_name, dst, fname, fpath, nbytes, payload, 'false', $_time_now, '-')
			forward(JSON.parse(msg))
		end
	end

	def self.handle_im_target(parsed_msg)
		src = parsed_msg['HEADER']['SENDER']
		
		fname = parsed_msg['HEADER']['FILE']
		fpath = parsed_msg['HEADER']['PATH']
		nbytes = parsed_msg['HEADER']['BYTES']
		payload = parsed_msg['PAYLOAD']
		dep_time = parsed_msg['HEADER']['DEPTIME']
		arr_time = $_time_now
		# save to disk
		arr = Fragmenter.chunkify(payload, 2)
		bytes = arr.pack('H2'*arr.size)
		file_path = fpath + "/"+ fname
		Utility.write_bytes(file_path, bytes)
		Logger.info("FTP: #{src} --> #{fpath}/#{fname}")

		# send ack
		msg = MessageBuilder.create_ftp_message($__node_name, src, fname, fpath, nbytes, '-', 'true', dep_time, arr_time)
		forward(JSON.parse(msg))
	end

	def self.handle_received_ack(parsed_msg)
		fname = parsed_msg['HEADER']['FILE']
		dst = parsed_msg['HEADER']['SENDER']
		nbytes = parsed_msg['HEADER']['BYTES']
		dep_time = parsed_msg['HEADER']['DEPTIME']
		arr_time = parsed_msg['HEADER']['ARRTIME']
		delta = Time.parse(arr_time) - Time.parse(dep_time)
		if delta == 0
			rate = nbytes
		else
			rate = nbytes / delta
		end
		Logger.info("#{fname} --> #{dst} in #{delta.to_i}s at #{rate.to_i}Bps")
	end

	def self.handle_transmission_error(parsed_msg)
		fname = parsed_msg['HEADER']['FILE']
		dst = parsed_msg['HEADER']['SENDER']
		byte_count = parsed_msg['HEADER']['BYTES']
		Logger.error("FTP ERROR: #{fname} --> #{dst} INTERRUPTED AFTER #{byte_count}")

	end

	def self.forward(parsed_msg)
		Thread.new do
			begin
				Router.forward_ftp(parsed_msg)
			rescue Exception => e
				if e.to_s == 'node not in table'
					Logger.error("#{e}")
				else
					dst = parsed_msg['HEADER']['SENDER']
					target = parsed_msg['HEADER']['TARGET']
					fname = parsed_msg['HEADER']['FILE']
					fpath = parsed_msg['HEADER']['PATH']
					nbytes = ((e.to_s.to_i) / 2) * ($__max_packet_size.to_i)
					# send transmission error back to source
					msg = MessageBuilder.create_ftp_message(target, dst, fname, fpath, nbytes, '-', 'error', '-', '-')
					Router.forward_ftp(JSON.parse(msg))
				end		
			end
		end
	end

end