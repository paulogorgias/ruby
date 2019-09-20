my_thread = Thread.new do
	while true do
		puts "thread here"
		Thread.stop
	end
end
time = 0
while time < 30 do
	puts "main thread here"
	my_thread.run	
	sleep 1
	time += 1
end
