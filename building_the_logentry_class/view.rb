class BasicView
	def clear_display	
		print "\e[2J"
	end

	def turn_off_cursor
		print "\e[?25l"
	end

	def turn_on_cursor
		print "\e[?25h"
	end

	def set_cursor row = 1, column = 1
		print "\e[#{row};#{column}H"
	end

	def center text
		columns = $stdin.winsize[1]
		text_length = text.length
		column_location = columns / 2 - text_length / 2
		text = "\e[#{column_location}G#{text}"
	end

	def red text
		"\e[31;40m#{text}\e[0m"
	end

end
class FileDialogView < BasicView
	def display log_file
		clear_display
		turn_off_cursor
		set_cursor
		puts red(center("Select an Apache log file."))
		update log_file
	end
	def update log_file
		set_cursor 2, 1
		log_file.directory.each_with_index do |directory_entry, index |
                        if index < log_file.list_start
                                next
                        end
                        if index > log_file.list_start + $stdin.winsize[0] - 3
                                break
                        end
                        directory_entry = directory_entry + "/" if Dir.exist?(log_file.file_path + directory_entry)
                        directory_entry = red(directory_entry) if index == log_file.directory_index
                        print directory_entry + "\e[K\n"
                        
		end
		print "\e[J"
		set_cursor $stdin.winsize[0], 1
		print red("Type 'q' to exit; up/down to move; return to select")
              
	end
	def quittable?
		true
	end

end

class LogListView < BasicView

	def display log_file
		clear_display
		set_cursor
		print red(center(log_file.file_name)) + "\n"
		update log_file
		
	end

	def update log_file
		set_cursor 2,1
		log_file.log_entries.each_with_index do |entry, index|
                        if index < log_file.list_start
                                next
                        end
                        if index > log_file.list_start + $stdin.winsize[0] - 3
                                break
                        end
                         
			total_columns = $stdout.winsize[1] - 28 # (space after ip address, response code, and file size)
			text_column_size = total_columns / 3
                        row = "\e[K" + entry.ip_address + "\e[17G" + entry.request.slice(0, text_column_size) + 
				"\e[#{text_column_size + 17 + 1}G" + entry.response_code +
				"\e[#{text_column_size + 17 + 1 + 4}G" + entry.http_referer.slice(0, text_column_size) + 
				"\e[#{2 * text_column_size + 17 + 2 + 4}G" + entry.user_agent.slice(0, text_column_size) + 
				"\e[#{3 * text_column_size + 17 + 3 + 4}G" + entry.file_size.slice(0, 7) + "\n"
			row = red(row) if index == log_file.log_entry_index
			print row
                end
                print "\e[J"
                set_cursor $stdin.winsize[0], 1
                print red("Type 'q' to exit, up/down to move, 's' to sort or filter");
	end

	def quittable?
		true
	end


end

class SortFilterView < BasicView
end

