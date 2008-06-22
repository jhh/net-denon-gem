require "test/unit"

require "net/denon"
require "mock_socket"

class TestSendCommand < Test::Unit::TestCase
  def test_should_power_on
    proxy = MockSocket.new()
    denon = Net::Denon::new(:proxy => proxy)
    assert_instance_of(Net::Denon, denon)
    
  end
end