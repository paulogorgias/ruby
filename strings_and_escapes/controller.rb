class LogParserController
	
	def initialize
		@log_file = LogFile.new
		@current_view = FileDialogView.new
		@current_view.clear_display
		@current_view.set_cursor
	end
	def run
		while true do
			@current_view.display
			break
		end	
	end
end
