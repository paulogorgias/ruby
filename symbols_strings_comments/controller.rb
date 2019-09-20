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
			if @current_view.quittable? && user_input == 'q'
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
			    end				
                        when "\e[A"
                           #up button ... update the view with a move action
                            case @current_view.class.to_s 
				when "FileDialogView"
					file_dialog_move -1
				when "LogListView"
					log_list_move -1
                            end
                        when "\e[B"
                            #down
			    case @current_view.class.to_s
                               	when "FileDialogView"
                               		file_dialog_move 1
				when "LogListView"
					log_list_move 1
                            end
                        when "\e[C"
                            #right
                        when "\e[D"
                             #left
			else
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
		case @log_file.select_directory_or_load_file
			when :directory
				@current_view.update @log_file
			when :file
				@current_view = LogListView.new
				@current_view.display @log_file
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


end
