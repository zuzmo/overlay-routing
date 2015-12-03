require 'test/unit'

require_relative '../message_builder'
require_relative '../fragmenter'
require_relative '../defragmenter'

class FragDefragTest < Test::Unit::TestCase

  # Called before every test method runs. Can be used
  # to set up fixture information.

  $__max_packet_size = 5000

  def setup
    # Do nothing
    
  end

  # Called after every test method runs. Can be used to tear
  # down fixture information.

  def teardown
    # Do nothing
  end

  # Fake test
  def test_fragmentation_defragmentation
    payload = '111222333444555666777'
    msg = MessageBuilder.create_flood_message('n1', payload)

    packet_arr = Fragmenter.fragment(msg)
    puts packet_arr
    
    msg = Defragmenter.defragment(packet_arr)
    puts msg

  end
end