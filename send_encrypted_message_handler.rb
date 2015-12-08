require 'json'
require 'openssl'

require_relative 'fragmenter'
require_relative 'message_builder'
require_relative 'graph'

class SendEncryptedMessageHandler

	def self.handle_from_console(dst, payload)
		if dst == $__node_name
			Logger.info("#{payload}") 
		else
			#======================================================
			# Now that we know the path, we need to create layers.
			# This is where Onion Routing begins.
			#======================================================
			path_to_dest = ["n1", "n3", "n4"]
			msg = create_packet_layers(payload, path_to_dest)

			begin 
				forward(JSON.parse(msg))
			rescue Exception => e
				puts e
			end

		end
	end

	def self.handle_received(parsed_msg)
		node = parsed_msg['HEADER']['TARGET']
		if node == $__node_name

			#==================================================
			# Decode the payload and the cipher token that 
			# is received from the sender
			#==================================================
			decoded_payload = decode(parsed_msg['PAYLOAD'])
			decoded_cipher_token = decode(parsed_msg['HEADER']['CIPHER_TOKEN'])

			#==================================================
			# Read the private_key to decrypt the key.
			#==================================================
			private_key_file = "/home/core/Desktop/project-3/overlay-routing/private_keys/#{node}.pem"
			private_key = OpenSSL::PKey::RSA.new File.read private_key_file
			cipher_stuff = private_key.private_decrypt(decoded_cipher_token)

			cipher_arr = cipher_stuff.split("%%")
			key = cipher_arr[0]
			iv = cipher_arr[1]

			#==================================================
			# Decrypt the data with the decrypted key and iv.
			#==================================================
			decipher = OpenSSL::Cipher::AES.new(128, :CBC)
			decipher.decrypt
			decipher.key = key
			decipher.iv = iv
			decrypted_payload = decipher.update(decoded_payload) + decipher.final

			# Forward if it's not a packet, otherwise print the decrypted result.
			if ((decrypted_payload.include? "HEADER") && (decrypted_payload.include? "PAYLOAD") && 
				(decrypted_payload.include? "TYPE"))
				begin
					forward(JSON.parse(decrypted_payload))
				rescue Exception => e
					puts e
				end
			else
				Logger.info("#{decrypted_payload}") 
			end
		end	
	end

	def self.create_packet_layers(payload, path_to_dest)		
		next_hop = path_to_dest.pop
		src = path_to_dest.pop
		
		#=====================================================================
		# Instantiating a Cipher. We will use Advanced Encryption Standard(AES)
		# with 128 bits of key and will use Cipher Block Chaining(CBC) mode.
		#=====================================================================
		cipher = OpenSSL::Cipher::AES.new(128, :CBC)
		cipher.encrypt
		key = cipher.random_key
		iv = cipher.random_iv
		encrypted_payload = cipher.update(payload) + cipher.final
		
		#===============================================
		# Any encrypted message cannot be saved in json, 
		# so we have to encode every character to H2.
		#===============================================
		encoded_payload = encode(encrypted_payload)

		# Reading the public key of a node.
		public_key_file = "/home/core/Desktop/project-3/overlay-routing/public_keys/#{next_hop}.pem"
		public_key = OpenSSL::PKey::RSA.new File.read public_key_file
		
		# Preparing the encrypted cipher token (key, iv) with public key and then encode it.
		cipher_token = "#{key}%%#{iv}"
		encrypted_cipher_token = public_key.public_encrypt(cipher_token)
		encoded_cipher_token = encode(encrypted_cipher_token)
		
		# Packet will keep building till the nodes in the array are empty.
		msg = MessageBuilder.create_send_encrypted_message(src, next_hop, encoded_cipher_token, encoded_payload)
		if path_to_dest.length != 0
			path_to_dest.push(src)
			create_packet_layers(msg, path_to_dest)
		else
			return msg
		end
	end

	def self.forward(parsed_msg)
		Router.forward(parsed_msg)
	end

	def self.encode(data)
		return (data.unpack('H2'*data.size))*""
	end

	def self.decode(data)
		arr = Fragmenter.chunkify(data, 2)
		data = arr.pack('H2'*arr.size)
		return data
	end

end
