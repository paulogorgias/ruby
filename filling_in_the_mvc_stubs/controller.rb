class LogParserController
	
	def initialize
		@log_file = LogFile.new
		@current_view = FileDialogView.new
		@current_view.display @log_file
	end
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

	def parse_input user_input
		case user_input
                	when "\n"
                            #change controller likely
                            #check the View's current interaction index to see what's next
				
                        when "\e[A"
                           #up button ... update the view with an up action
                            case @current_view.class.to_s 
				when "FileDialogView"
					file_dialog_move -1
                            end
                        when "\e[B"
                            #down
			    case @current_view.class.to_s
                               when "FileDialogView"
                               		file_dialog_move 1
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

	def file_dialog_move increment
		@log_file.directory_index += increment
                if @log_file.directory_index < @log_file.list_start
                      @log_file.list_start = @log_file.directory_index - $stdin.winsize[0] + 3
                elsif @log_file.directory_index > @log_file.list_start + $stdin.winsize[0] - 3
                      @log_file.list_start = @log_file.directory_index
                end
                @current_view.update @log_file
	end

end
