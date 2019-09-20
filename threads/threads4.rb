thread = Thread.new do
	Thread.current.thread_variable_set "my_var", 1
	Thread.stop
	Thread.current.thread_variable_set "my_var", 2
end

puts thread.thread_variable_get "my_var"
thread.run
puts thread.thread_variable_get "my_var"
