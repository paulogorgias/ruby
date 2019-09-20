
my_thread = Thread.new do
	while true do
		puts "thread here"
		sleep 0.1
	end
end
time = 0
while time < 30 do
	puts "main thread here"
	sleep 1
	time += 1
end
