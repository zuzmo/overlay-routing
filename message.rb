require 'json'

class Message

  def initialize
    @msg = {'header' => {}, 'payload' => {}}
  end

  def add_to_header(key, value)
    @msg['header'][key] = value

  end

  def add_to_payload(key, value)
    @msg['payload'][key] = value
  end

  def to_json
    @msg.to_json
  end

  def get_header_num_bytes
    @msg['payload']
  end

end

# msg = Message.new
# msg.add_to_header('seq', 1)
# msg.add_to_payload('table', {'k' => 3, 'l' => 9})
# msg.add_to_payload('bs', ['k', 3, 'l', 9]).size
# puts msg.to_json