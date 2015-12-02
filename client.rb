require 'socket'

class Client

  def self.send(msg, ip, port)
    socket = TCPSocket.open(ip, port)
    packets = Fragmenter.fragment(msg)
    packets.each{ |p| socket.puts(p) }
    socket.close
  end

  def self.send_local(msg, port)
    socket = TCPSocket.open('0.0.0.0', port)
    packets = Fragmenter.fragment(msg)
    packets.each{ |p| socket.puts(p) }
    socket.close
  end

end
