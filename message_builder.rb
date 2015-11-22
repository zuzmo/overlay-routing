require 'json'

class Messages

	def self.create_flood_message(sender,sequence)
		flood_message = {
			"HEADER" => 
			  {"TYPE" => "FLOOD",
			   "SENDER" => "#{sender}",
               "SEQUENCE" => "#{sequence}"  
			  }
		}

		flood_message.to_json


	end

end
