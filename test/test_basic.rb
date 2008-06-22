require "test/unit"

require File.expand_path(
    File.join(File.dirname(__FILE__), %w[.. lib net denon]))

require File.join(File.dirname(__FILE__), %w[mock_socket])

class TestBasic < Test::Unit::TestCase

  def test_should_initialize
    proxy = MockSocket.new()
    denon = Net::Denon::Session::new(:proxy => proxy)
    assert_instance_of(Net::Denon::Session, denon)
    denon.close
  end
  
  def test_should_open_debug_log
    proxy = MockSocket.new()
    denon = Net::Denon::start(:proxy => proxy, :log => "debug.txt")
    denon.close
    assert(denon.closed?, "should be closed")
  end
  
  def test_should_not_connect_to_localhost
    # this will fail if you have a telnet server running
    assert_raise(Errno::ECONNREFUSED) do
      denon = Net::Denon::start(:host => "localhost", :log => "debug.txt")
    end
  end
  
  def test_should_timeout_connecting
    assert_raise(Timeout::Error) do
      denon = Net::Denon::start(:host => "www.google.com", :log => "debug.txt")    
    end
  end
end