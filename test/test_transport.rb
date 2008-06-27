require 'common'
require 'net/denon/transport'

class TestTransport < Test::Unit::TestCase

  def test_constructor_defaults
    assert_equal("net.denon.test", transport.host)
    assert_equal(23, transport.port)
  end
  
  def test_close_should_close_socket
    transport!
    socket.expects(:close)
    transport.close
  end

  private
  
  def socket
    @socket ||= Object.new
  end
    
  
  def transport(options={})
    @session ||= begin
      host = options.delete(:host) || "net.denon.test"
      TCPSocket.stubs(:open).with(host, options[:port] || 23).returns(socket)
      Net::Denon::Transport.new(host, options)
    end
  end
  
  # a simple alias to make the tests more self-documenting. the bang version
  # makes it look more like the transport object is being instantiated
  alias transport! transport

end