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

  def self.send_ftp(msg, ip, port)
      packets = Fragmenter.fragment(msg)
      num_packets_sent = 0
      begin
        socket = TCPSocket.open(ip, port)
        packets.each do |p| 
          socket.puts(p)
          num_packets_sent += 1
        end
        socket.close
      rescue
        # interrumpted transmission
        npackets = num_packets_sent.to_s
        raise Exception, npackets
      end
  end

end
