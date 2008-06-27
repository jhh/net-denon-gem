require 'common'
require 'net/denon/session'
require 'net/denon/transport'
require 'net/denon/constants'

class TestSession < Test::Unit::TestCase
  include Net::Denon::Constants

  def test_constructor_defaults
    assert_equal("net.denon.test", session.transport.host)
    assert_equal(23, session.transport.port)
    assert_kind_of(Net::Denon::State, session.state)
  end
  
  def test_close_should_close_socket
    session!
    socket.expects(:close)
    session.close
  end
  
  def test_should_power_on_when_state_is_standby
    transport.expects(:send).with(POWER_STATUS).in_sequence(test_sequence)
    transport.expects(:poll_events).returns(POWER_STANDBY + CR).in_sequence(test_sequence)
    transport.expects(:send).with(POWER_ON).in_sequence(test_sequence)
    transport.expects(:poll_events).returns(POWER_ON + CR).in_sequence(test_sequence)
    session.on!
    assert(session.state.on?, "State should be on.")
  end

  def test_should_not_power_on_when_state_is_on
    transport.expects(:send).with(POWER_STATUS).in_sequence(test_sequence)
    transport.expects(:poll_events).returns(POWER_ON + CR).in_sequence(test_sequence)
    transport.expects(:send).never.in_sequence(test_sequence)
    session.on!
    assert(session.state.on?, "State should be on.")
  end

  def test_should_power_standby_when_state_is_on
    transport.expects(:send).with(POWER_STATUS).in_sequence(test_sequence)
    transport.expects(:poll_events).returns(POWER_ON + CR).in_sequence(test_sequence)
    transport.expects(:send).with(POWER_STANDBY).in_sequence(test_sequence)
    transport.expects(:poll_events).returns(POWER_STANDBY + CR).in_sequence(test_sequence)
    session.standby!
    assert(session.state.standby?, "State should be standby.")
  end

  def test_should_not_power_standby_when_state_is_standby
    transport.expects(:send).with(POWER_STATUS).in_sequence(test_sequence)
    transport.expects(:poll_events).returns(POWER_STANDBY + CR).in_sequence(test_sequence)
    transport.expects(:send).never.in_sequence(test_sequence)
    session.standby!
    assert(session.state.standby?, "State should be standby.")
  end

  def test_should_mute_when_state_is_unmute
    transport.expects(:send).with(MUTE_STATUS).in_sequence(test_sequence)
    transport.expects(:poll_events).returns(MUTE_OFF + CR).in_sequence(test_sequence)
    transport.expects(:send).with(MUTE_ON).in_sequence(test_sequence)
    transport.expects(:poll_events).returns(MUTE_ON + CR).in_sequence(test_sequence)
    session.mute!
    assert(session.state.mute?, "Mute should be on.")
  end

  def test_should_not_mute_when_state_is_mute
    transport.expects(:send).with(MUTE_STATUS).in_sequence(test_sequence)
    transport.expects(:poll_events).returns(MUTE_ON + CR).in_sequence(test_sequence)
    transport.expects(:send).never.in_sequence(test_sequence)
    session.mute!
    assert(session.state.mute?, "Mute should be on.")
  end

  def test_should_unmute_when_state_is_mute
    transport.expects(:send).with(MUTE_STATUS).in_sequence(test_sequence)
    transport.expects(:poll_events).returns(MUTE_ON + CR).in_sequence(test_sequence)
    transport.expects(:send).with(MUTE_OFF).in_sequence(test_sequence)
    transport.expects(:poll_events).returns(MUTE_OFF + CR).in_sequence(test_sequence)
    session.unmute!
    assert(!session.state.mute?, "Mute should be off.")
  end

  def test_should_not_unmute_when_state_is_unmute
    transport.expects(:send).with(MUTE_STATUS).in_sequence(test_sequence)
    transport.expects(:poll_events).returns(MUTE_OFF + CR).in_sequence(test_sequence)
    transport.expects(:send).never.in_sequence(test_sequence)
    session.unmute!
    assert(!session.state.mute?, "Mute should be off.")
  end

  private
  
  def test_sequence
    @test_sequence ||= sequence('test_sequence')
  end
  
  def socket
    @socket ||= Object.new
  end
  
  def transport
    session.transport
  end
    
  
  def session(options={})
    @session ||= begin
      host = options.delete(:host) || "net.denon.test"
      TCPSocket.stubs(:open).with(host, options[:port] || 23).returns(socket)
      Net::Denon::Session.new(host, options)
    end
  end
  
  # a simple alias to make the tests more self-documenting. the bang version
  # makes it look more like the transport object is being instantiated
  alias session! session

end