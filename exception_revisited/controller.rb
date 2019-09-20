class LogParserController

	#####################################
	# Setup basic components... get an
	# object of LogFile, and a view
	# to display the correct part of the 
	# program. Also display the view.
	#####################################	
	def initialize
		@log_file = LogFile.new
		@current_view = FileDialogView.new
		@current_view.display @log_file
	end

	#########################################
	# The program loop starts here.
	# It checks for input on each iteration, 
	# then reads the full input buffer and
	# send the data along to the parse_input
	# method. Handles exits too.
	#########################################
	def run
		while user_input = $stdin.getch do
			#process the input
			begin
				while next_chars = $stdin.read_nonblock(10) do
					user_input = "#{user_input}#{next_chars}"
				end
			rescue IO::WaitReadable
			end
			if @current_view.quittable? && user_input == "\e"
				@current_view.turn_on_cursor
				break
			else
				parse_input user_input
			end

		end	
	end


	###################################
	# separates out the kind of input
	# and calls the correct action
	###################################
	def parse_input user_input
		case user_input
                	when "\n" , "\r"
                            #carriage return / new line received
			    case @current_view.class.to_s
				when "FileDialogView"
					file_dialog_select
				when "SortFilterView"
					apply_sort_filter
				
			    end				
                        when "\e[A"
                           #up button ... update the view with a move action
                            case @current_view.class.to_s 
				when "FileDialogView"
					file_dialog_move -1
				when "LogListView"
					log_list_move -1
				when "SortFilterView"
					move_filter_selection -1
                            end
                        when "\e[B"
                            #down
			    case @current_view.class.to_s
                               	when "FileDialogView"
                               		file_dialog_move 1
				when "LogListView"
					log_list_move 1
				when "SortFilterView"
					move_filter_selection 1
                            end
                        when "\t"
                            case @current_view.class.to_s
				when "SortFilterView"
					move_filter_field 1
			    end
                        when "\e[D", "\e[C"
                             #left and right
			else
			    case @current_view.class.to_s
				when "LogListView"
					sort_select if user_input == "s"
			    	when "SortFilterView"
					if user_input == "\e"
						escape_sort_filter
					else
						input_filter_field user_input
					end
				end
			   #send other input to a selected input field
	
                end

	end

# ---------  actions  ----------- #


	#################################
	# moves the file dialog display's
	# highlight up or down
	#################################
	def file_dialog_move increment
		@log_file.directory_index += increment
		
		# keep the highlight within bounds
		@log_file.directory_index = 0 if @log_file.directory_index < 0
		@log_file.directory_index = @log_file.directory.entries.length - 1 if @log_file.directory_index > @log_file.directory.entries.length - 1

		# move the list_start variable to the correct place for next screen load of data
                if @log_file.directory_index < @log_file.list_start
                      @log_file.list_start = @log_file.directory_index - $stdin.winsize[0] + 3
                elsif @log_file.directory_index > @log_file.list_start + $stdin.winsize[0] - 3
                      @log_file.list_start = @log_file.directory_index
                end

		# update the display
                @current_view.update @log_file
	end


	#######################################
	# Applies the current file dialog 
	# selection which may change directory
	# or result in loading a file
	#######################################
	def file_dialog_select
		begin
			case @log_file.select_directory_or_load_file
				when :directory
					@current_view.update @log_file
				when :file
					@current_view = LogListView.new
					@current_view.display @log_file
			end
		rescue NotAnApacheAccessLog
			@current_view.notice "File does not conform to Access Log pattern"
		rescue NoFileAccess, NoDirAccess
			@current_view.notice "File or Directory Access Not Permitted"
		end
	end

	
	######################################
	# similar code to file_dialog_move,
	# moves the cursor up and down
	# while scrolling the screen contents
	# too
	######################################
	def log_list_move increment
		@log_file.log_entry_index += increment
		@log_file.log_entry_index = 0 if @log_file.log_entry_index < 0
		@log_file.log_entry_index = @log_file.log_entries.length - 1 if @log_file.log_entry_index > @log_file.log_entries.length - 1
                if @log_file.log_entry_index < @log_file.list_start
                      @log_file.list_start = @log_file.log_entry_index - $stdin.winsize[0] + 3
                elsif @log_file.log_entry_index > @log_file.list_start + $stdin.winsize[0] - 3
                      @log_file.list_start = @log_file.log_entry_index
                end
                @current_view.update @log_file

	end

	######################################################
	# The user wants to user the sort/filter functionality
	# so we need to display it
	######################################################
	def sort_select
		@current_view = SortFilterView.new
		@current_view.display @log_file.sort_filter
	end

	############################################
	# The user wants to exit sort/filter without
	# applying changes
	############################################
	def escape_sort_filter
		@current_view = LogListView.new
		@current_view.display @log_file
	end

	#####################################
	# The user is tabbing to a different
	# field in the sort/filter
	#####################################
	def move_filter_field increment
		@log_file.sort_filter.field_name_index += increment
		if @log_file.sort_filter.field_name_index >=  @log_file.sort_filter.field_list.length
			@log_file.sort_filter.field_name_index = 0 
		end
		@current_view.update @log_file.sort_filter
	end

	################################
	# The user is moving up and down
	# selecting a way to sort stuff
	################################
	def move_filter_selection increment
		current_field = @log_file.sort_filter.field_name_index
		field_list = @log_file.sort_filter.field_list
		
		if field_list[current_field][1] != nil && field_list[current_field][1].class != String 
			@log_file.sort_filter.field_selection[current_field] += increment
			if @log_file.sort_filter.field_selection[current_field] >= field_list[current_field][1].length
				@log_file.sort_filter.field_selection[current_field] = field_list[current_field][1].length - 1
			end
			@log_file.sort_filter.field_selection[current_field] = 0 if @log_file.sort_filter.field_selection[current_field] < 0
			@current_view.update @log_file.sort_filter
		end
	end

	#################################
	# The user is typing into a field
	#################################
	def input_filter_field user_input
		current_field = @log_file.sort_filter.field_name_index
		if @log_file.sort_filter.field_list[current_field][1] == nil
			@log_file.sort_filter.field_list[current_field][1] = user_input
		elsif @log_file.sort_filter.field_list[current_field][1].class == String
			if user_input == "\u007F"
				@log_file.sort_filter.field_list[current_field][1].gsub! /.$/, ""
			else
				@log_file.sort_filter.field_list[current_field][1] += user_input
			end
		end
		@current_view.update @log_file.sort_filter
	end

	########################
	# Take the data and run
	# the sort/filter 
	# algorithm
	########################
	def apply_sort_filter
		begin
			@log_file.log_entries = []
			@log_file.select_directory_or_load_file
			@log_file.sort_filter.apply_selections @log_file
			@current_view = LogListView.new
			@current_view.display @log_file
		rescue IPAddr::InvalidAddressError
			@current_view.notice "Please input a valid IP address"
		rescue InvalidDate
			@current_view.notice "Please input a date and time 'MM-DD HH:MM:SS'"
		end
	end

end
