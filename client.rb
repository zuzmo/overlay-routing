require 'socket'

hostname = 'localhost'
port = 7000

s = TCPSocket.open(hostname, port)

# while line = gets
# line = gets
# puts line.chop
# end


while line = s.gets
  print line
end

# s.send 'Hi from client'
# STDOUT.flush
# msg = s.gets
# print msg
# s.puts Thread.current.object_id


s.close