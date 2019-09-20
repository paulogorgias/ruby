class LogParserController
	
	def initialize
		@log_file = LogFile.new
		@current_view = FileDialogView.new
		@current_view.clear_display
		@current_view.set_cursor
		@current_view.display
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
                        when "\e[B"
                            #down
                        when "\e[C"
                            #right
                        when "\e[D"
                             #left
			else
			   #send other input to a selected input field
	
                end

	end
end
