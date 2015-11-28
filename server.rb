require 'socket'
require_relative 'defragmenter'
require_relative 'message_filter'

#==========================================================
# Server just accepts client's messages (arrive in packets) 
# and passes them to the MessageFilter
#==========================================================

class Server

  @@socket = nil

  def self.run(node_name, port)
    socket = TCPServer.open('', port)
    loop {
      Thread.start(socket.accept) do |client|
        packets = []
        while packet = client.gets
          packets << packet
        end
        client.close
        parsed_msg = Defragmenter.defragment(packets)  # assemble message
        MessageFilter.handle(parsed_msg)
      end
    }
  end

end