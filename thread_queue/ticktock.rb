require 'thread'
my_queue = Queue.new
my_var = ""
my_thread = Thread.new do
	10.times do
		my_queue << "tock"
	end	
end
10.times do
	my_var += "tick"
	my_var += my_queue.pop
	puts "Value: \t#{my_var}"
end
