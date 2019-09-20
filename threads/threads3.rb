my_var = ""

my_thread = Thread.new do
	10.times do
		my_var += "tock"
		Thread.pass
	end
end

10.times do
	my_var += "tick"
	puts "Value: #{my_var}"
	Thread.pass
end
