class LogParserController
	
	def initialize
		@logfile = LogFile.new
		@currentView = FileDialogView.new
	end
	def run
		while true do
			@currentView.display
			break
		end	
	end
end
