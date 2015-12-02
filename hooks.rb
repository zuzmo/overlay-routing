require_relative 'link_state_manager'

class Hooks

	def self.dump_table(fname)
		data = LinkStateManager.get_table_data
		Utility.write_string_to_file(fname, data)
	end


	def self.force_update
		LinkStateManager.broadcast_link_state
	end

	def self.check_stable
		if LinkStateManager.check_stable?
			puts 'yes'
		else
			puts 'no'
		end
	end
end