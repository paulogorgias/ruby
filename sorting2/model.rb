require 'ipaddr'
class LogFile
	attr_accessor :file_name, :file_path, :log_entries, :directory, :directory_index, :log_entry_index, :list_start, :sort_filter
	
	############################### 
	#  Setup the object ... 
	#  make sure @log_entries is an
	#  array
	###############################
	def initialize
		cd "./"
		@log_entries = Array.new
		@sort_filter = SortFilter.new
	end

	###############################
	# change directory of LogFile
	# object to path, if possible.
	# If not, return false.
	###############################
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

	######################################
	# Once the user has chozen a file
	# we need to load data from the file
	# into our log_entries array
	######################################
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

	#####################################
	# method which figures out what do to
	# with a user's selection. It may be 
	# a file or directory. If it's a 
	# directory, change into it and 
	# return symbol :directory. If it's
	# a file, load it, and return :file
	#####################################
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

	######################################
	# LogEntry is an object represntation
	# of all the data of a row from a
	# log file, so we pass a row of string
	# data from the log_file, and parse it
	######################################	
	def initialize row = nil
		if row
			row.gsub! /\t/, "     "
			match_data = parse_row row
			set_properties match_data
		end
	end


	########################################
	# load the properties into variables
	# from match_data, the MatchData object
	# which comes from parsing with a regex
	########################################
	def set_properties match_data
		@ip_address = IPAddr.new match_data[1]
		@request = match_data[10]
		@response_code = match_data[11]
		@file_size = match_data[12]
		@http_referer = match_data[13]
		@user_agent = match_data[14]
		@time_stamp = Time.gm match_data[6], match_data[5], match_data[4], match_data[7], match_data[8], match_data[9]
	end



	##################################
	# parse_row wraps up our regular
	# expression
	##################################

	def parse_row row
		# Match		IP Address		    User and Computer		Time Stamp					Request   Code	Size	Referer	  Agent
		regex = /(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}) (\S*) (\S*) \[(\d\d)\/([^\/]*)\/(\d{4}):(\d\d):(\d\d):(\d\d) [\+-]\d{4}\] "([^"]*)" (\S+) (\S+) "([^"]*)" "([^"]*)"/
		regex.match row
	end


end
class SortFilter
	attr_accessor :field_list, :field_name_index, :field_selection

	##############################################
	# Setup the sort/filter object
	# @field_list = multidimensional
	# array[a][b][c]
	# a => different fields
	# b => 0 = field_name, 
	#	1 = [array of choices], 
	#	or 1 = input from user
	# c => possible responses in 
	# choice list
	# @field_name_index => current selected field
	# @field_selection => selections of c, above
	#############################################
	def initialize
		@field_list = [
			[:sort_by, [:none, :time_stamp, :ip_address, :file_size]], 
			[:sort_direction, [:asc, :desc]],
			[:time_stamp],
			[:ip_address],
			[:request]]
		@field_name_index = 0
		@field_selection = [0,0]
		
		
	end


	#################################
	# Applies the selections of the 
	# sort filter to the log_entries
	# in the log_file passed in to 
	# the method
	# this is a destructive method
	# subsequent reload will
	# be required for filter changes
	################################

	def apply_selections log_file
		#first sort the file
		if @field_selection[0] != 0	
				if @field_selection[1]==0
					#sort by selected symbol asc
					log_file.log_entries.sort! do |entry_a, entry_b|
						entry_a.send(@field_list[0][1][@field_selection[0]]).to_i <=> entry_b.send(@field_list[0][1][@field_selection[0]]).to_i
					end
				else
					#sort by selected symbol desc
                                        log_file.log_entries.sort! do |entry_a, entry_b|
                                                entry_b.send(@field_list[0][1][@field_selection[0]]).to_i <=> entry_a.send(@field_list[0][1][@field_selection[0]]).to_i
                                        end
				end
		end

		#apply the time stamp filter
		if @field_list[2][1] != "" && @field_list[2][1] != nil
			#apply a time stamp filter
			regex = /(..)[\/-](..)\s(..):(..):(..)/
			matches = @field_list[2][1].match regex
			if matches != nil
				if matches[1] != "**"
					log_file.log_entries.select! do | entry |
						entry.time_stamp.month == matches[1].to_i
					end
				end
				if matches[2] != "**"
                                	log_file.log_entries.select! do | entry |
                                               	entry.time_stamp.day == matches[2].to_i
                               	       end
                       		end
				if matches[3] != "**"
                                        log_file.log_entries.select! do | entry |
               	                                entry.time_stamp.hour == matches[3].to_i
                                       	end
        	              	end
				if matches[4] != "**"
                               	        log_file.log_entries.select! do | entry |
                                       	        entry.time_stamp.min == matches[4].to_i
                               	    	end
                       		end
				if matches[5] != "**"
                                       	log_file.log_entries.select! do | entry |
                                               	entry.time_stamp.sec == matches[5].to_i
                                       	end
                        	end
			end
		end
		
		# apply the ip address filter
		if @field_list[3][1] != "" && @field_list[3][1] != nil
                        #apply an ip filter
			ip_address_range = IPAddr.new(field_list[3][1])
			log_file.log_entries.select! do | entry |
				ip_address_range.include? entry.ip_address
			end
                end

		# apply the request filter
		if @field_list[4][1] != "" && @field_list[4][1] != nil
                        log_file.log_entries.select! do | entry |
				entry.request.include? field_list[4][1]
			end 
               end
		
	end	
end
