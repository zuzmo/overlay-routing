require 'socket'
require 'json'

class Client

  def self.send(msg, ip, port)
    socket = TCPSocket.open(ip, port)
    packets = Fragmenter.fragment(msg)
    packets.each{ |p| socket.puts(p) }
    socket.close
  end

end
