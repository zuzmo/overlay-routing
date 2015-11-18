Thread.new do
	loop do
		puts "XXXX"
		s = gets.chomp
		puts "You entered #{s}"
		exit if s == 'end'
	end
end

i = 0
loop do
	puts "And the script is still running (#{i})..."
	i += 1
	sleep 1
end