class Clock


	# =========================================================================
	# This class gets the current time at initialization from the OS and 
	# updates it when told to.
	# =========================================================================


	# =========================================================================
	# Sets up the time constant and sets it to the OS time.
	# =========================================================================
	def initialize
		@time = Time.new
	end


	# =========================================================================
	# Returns the current stored time.
	# =========================================================================
	def get_time
		@time.inspect
	end

	
	# =========================================================================
	# Updates the time.
	# Params:
	#        +seconds -> the amount of seconds to add to the clock
	# =========================================================================
	def tick(seconds)
		@time += seconds
	end

	def get_formatted_time()
		time = @time
		hour = format('%02d',"#{time.hour}")
		min = format('%02d',"#{time.min}")
		sec = format('%02d',"#{time.sec}")
		return "#{hour}:#{min}:#{sec}"
	end
end



