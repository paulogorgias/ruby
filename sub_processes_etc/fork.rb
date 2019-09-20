my_string = "abc"
puts "Before the fork my_string: #{my_string}"
fork do
	my_string = "def"
	puts "In the fork my_string changed to: #{my_string}"
end
sleep 1
puts "After the fork: #{my_string}"
