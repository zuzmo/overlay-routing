class Clock


	# =========================================================================
	# This class gets the current time at initialization from the OS and 
	# updates it when told to
	# =========================================================================


	# =========================================================================
	# Sets up the time constant and sets it to the OS time
	# =========================================================================
	def initialize

		@time = Time.new

	end


	# =========================================================================
	# Returns the current stored time
	# =========================================================================
	def get_time
		@time.inspect
	end

	
	# =========================================================================
	# Updates the time
	# 1st. seconds:
	#        The amount of secods to add to the clock
	# =========================================================================
	def tick(seconds)
		@time += seconds
	end


end



