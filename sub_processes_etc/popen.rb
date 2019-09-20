puts "Enter a filename"
filename = gets 
puts "Ruby will open up vim."
IO.popen "vim ./#{filename}", "r+" do |vim_program|
	vim_program.write "\r"
	vim_program.write "i"
	puts "Enter the first line of your file"
	file_text = gets
	vim_program.write file_text
	vim_program.puts "\e:w"
	vim_program.puts ":q"
	vim_program.close
end
puts "Finished"
