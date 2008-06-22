require "test/unit"

require File.expand_path(
    File.join(File.dirname(__FILE__), %w[.. lib net denon]))

require File.join(File.dirname(__FILE__), %w[mock_socket])


class TestSendCommand < Test::Unit::TestCase
  def test_should_power_on
    proxy = MockSocket.new()
    denon = Net::Denon::start(:proxy => proxy)
    assert_instance_of(Net::Denon::Session, denon)
    
  end
end