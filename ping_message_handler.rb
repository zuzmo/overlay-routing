require 'json'
require 'time.rb'
require_relative 'fragmenter'
require_relative 'message_builder'

# TODO:
# 1. PING to itself?

class PingMessageHandler

  def self.handle_from_console(dst, num_pings, delay)



    # Build a packet and forward.
    packet = MessageBuilder.create_ping_message($__node_name, dst, num_pings, $_time_now)

    # Set the values of seq and ack back to 0.
    packet = (JSON.parse(packet))
    packet['HEADER']['SEQUENCE'] = 0
    packet['HEADER']['ACK'] = 0

	if dst == $__node_name
  		Client.send_local(packet.to_json, $__port)
  	end

    @delay_time = delay

    begin
    forward(JSON.parse(packet.to_json))
	rescue Exception => e
		puts e
	end

  end

  def self.handle_received(parsed_msg)

    if parsed_msg['HEADER']['TARGET'] == $__node_name

      seq = parsed_msg['HEADER']['SEQUENCE'].to_i
      ack = parsed_msg['HEADER']['ACK'].to_i
      num_pings = parsed_msg['HEADER']['NUM_PINGS'].to_i
      sender = parsed_msg['HEADER']['TARGET']
      target = parsed_msg['HEADER']['SENDER']


      #===========================================================
      # If seq = 0, ack = 0, then dest received a packet from src.
      # If seq = 0, ack = 1, then src received a packet from dest.
      # If seq = 1, ack = 1, then dest received a packet from src.
      # If seq = 1, ack = 2, then src received a packet from dest.
      #
      # Basically, when seq == ack, that means src has sent a packet to dest.
      # Otherwise, dest has sent a packet to src.
      #===========================================================

      if seq == ack

        # Creating a new packet, which will be sent by dest to src
        # with sender and target swapped and incrementing ack.

        parsed_msg['HEADER']['TARGET'] = target
        parsed_msg['HEADER']['SENDER'] = sender
        parsed_msg['HEADER']['ACK'] = ack + 1

        forward(JSON.parse(parsed_msg.to_json))
      else

        # Src needs to transmit [num_pings] number of packets to dest.
        # Src updates the value of ['NUM_PINGS'] number of packets more on way.

        if num_pings == 0
          # All packets have been sent [num_pings] times.

        else

          print_result(parsed_msg, seq, target)


          # Sleep for [@delay_time] before sending another packet.
          sleep(@delay_time)

          # Creating a new packet, which will be sent by src to dest
          # with sender and target swapped and incrementing seq.

          parsed_msg['HEADER']['TARGET'] = target
          parsed_msg['HEADER']['SENDER'] = sender
          parsed_msg['HEADER']['SEQUENCE'] = seq + 1
          parsed_msg['HEADER']['NUM_PINGS'] = num_pings - 1
          parsed_msg['HEADER']['TIME_SENT'] = $_time_now

          forward(JSON.parse(parsed_msg.to_json))
        end

      end


    else
      # Keep forwarding until dest is reached.
      forward(parsed_msg)
    end
  end

  def self.print_result(parsed_msg, seq, target)

    # Calculate the RTT between the packet sent from src to dest and dest to src.
    time_sent = Time.parse(parsed_msg['HEADER']['TIME_SENT'])
    time_diff = Time.parse($_time_now) - time_sent

    if time_diff > $__ping_timeout.to_f
      puts "PING ERROR: HOST UNREACHABLE"
    else
      puts "#{seq} #{target} #{time_diff}"
    end

  end

  def self.forward(parsed_msg)
    Router.forward(parsed_msg)
  end

end