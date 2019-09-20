class LogFile
	attr_accessor :file_name, :file_path, :log_entries, :directory, :directory_index, :log_entry_index, :list_start
	def initialize
		cd "/"
		@log_entries = Array.new
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
                        log_array = IO.readlines(@file_path + @file_name)
			log_array.each_with_index do |log, index|
				@log_entries[index] = LogEntry.new log
			end
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

	attr_accessor :ip_address, :time_stamp, :request, 
		:response_code, :file_size, :http_referer, :user_agent
	def initialize row = nil
		if row
			row.gsub! /\t/, "     "
			match_data = parse_row row
			set_properties match_data
		end
	end
	def set_properties match_data
		@ip_address = match_data[1]
		@request = match_data[10]
		@response_code = match_data[11]
		@file_size = match_data[12]
		@http_referer = match_data[13]
		@user_agent = match_data[14]
	end


	def parse_row row
		regex = /(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}) (\S*) (\S*) \[(\d\d)\/([^\/]*)\/(\d{4}):(\d\d):(\d\d):(\d\d) [\+-]\d{4}\] "([^"]*)" (\S+) (\S+) "([^"]*)" "([^"]*)"/
		regex.match row
	end


end
