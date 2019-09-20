class LogFile
	attr_accessor :file_name, :file_path, :log_entries, :directory, :directory_index, :log_entry_index, :list_start
	def initialize
		cd "/"
	end

	def cd path
		if Dir.exist?(path)
			@file_path = path
			@directory = Dir.new(@file_path)
			@directory_index = 0
			@list_start = 0
			true
		else
			false
		end	
	end

	def load_file
		if File.file?(@file_path + @directory.entries[@directory_index])
                	@file_name = @directory.entries[@directory_index]
                        @log_entries = IO.readlines(@file_path + @file_name)
			@log_entry_index = 0
			@list_start = 0
			true
                else
			false
		end
	end
	def select_directory_or_load_file
                if cd(@file_path + @directory.entries[@directory_index] + "/")
                        :directory
                else
			if load_file
				:file
			end

                end

	end

end

class LogEntry
end
