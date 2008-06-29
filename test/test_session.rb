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
    transport.expects(:poll_events).returns(power_event(false)).in_sequence(test_sequence)
    transport.expects(:send).with(POWER_ON).in_sequence(test_sequence)
    transport.expects(:poll_events).returns(power_event(true)).in_sequence(test_sequence)
    session.on!
    assert(session.state.on?, "State should be on.")
  end

  def test_should_not_power_on_when_state_is_on
    transport.expects(:send).with(POWER_STATUS).in_sequence(test_sequence)
    transport.expects(:poll_events).returns(power_event(true)).in_sequence(test_sequence)
    transport.expects(:send).never.in_sequence(test_sequence)
    session.on!
    assert(session.state.on?, "State should be on.")
  end

  def test_should_power_standby_when_state_is_on
    transport.expects(:send).with(POWER_STATUS).in_sequence(test_sequence)
    transport.expects(:poll_events).returns(power_event(true)).in_sequence(test_sequence)
    transport.expects(:send).with(POWER_STANDBY).in_sequence(test_sequence)
    transport.expects(:poll_events).returns(power_event(false)).in_sequence(test_sequence)
    session.standby!
    assert(session.state.standby?, "State should be standby.")
  end

  def test_should_not_power_standby_when_state_is_standby
    transport.expects(:send).with(POWER_STATUS).in_sequence(test_sequence)
    transport.expects(:poll_events).returns(power_event(false)).in_sequence(test_sequence)
    transport.expects(:send).never.in_sequence(test_sequence)
    session.standby!
    assert(session.state.standby?, "State should be standby.")
  end

  def test_should_mute_when_state_is_unmute
    transport.expects(:send).with(MUTE_STATUS).in_sequence(test_sequence)
    transport.expects(:poll_events).returns(mute_event(false)).in_sequence(test_sequence)
    transport.expects(:send).with(MUTE_ON).in_sequence(test_sequence)
    transport.expects(:poll_events).returns(mute_event(true)).in_sequence(test_sequence)
    session.mute!
    assert(session.state.mute?, "Mute should be on.")
  end

  def test_should_not_mute_when_state_is_mute
    transport.expects(:send).with(MUTE_STATUS).in_sequence(test_sequence)
    transport.expects(:poll_events).returns(mute_event(true)).in_sequence(test_sequence)
    transport.expects(:send).never.in_sequence(test_sequence)
    session.mute!
    assert(session.state.mute?, "Mute should be on.")
  end

  def test_should_unmute_when_state_is_mute
    transport.expects(:send).with(MUTE_STATUS).in_sequence(test_sequence)
    transport.expects(:poll_events).returns(mute_event(true)).in_sequence(test_sequence)
    transport.expects(:send).with(MUTE_OFF).in_sequence(test_sequence)
    transport.expects(:poll_events).returns(mute_event(false)).in_sequence(test_sequence)
    session.unmute!
    assert(!session.state.mute?, "Mute should be off.")
  end

  def test_should_not_unmute_when_state_is_unmute
    transport.expects(:send).with(MUTE_STATUS).in_sequence(test_sequence)
    transport.expects(:poll_events).returns(mute_event(false)).in_sequence(test_sequence)
    transport.expects(:send).never.in_sequence(test_sequence)
    session.unmute!
    assert(!session.state.mute?, "Mute should be off.")
  end

  def test_should_set_master_volume
    transport.expects(:send).with(volume_command(23)).in_sequence(test_sequence)
    transport.expects(:poll_events).returns(volume_event(23, 33)).in_sequence(test_sequence)
    session.master_volume=23
    assert_equal(23, session.state.master_volume)
    assert_equal(33, session.state.master_volume_max)
  end

  def test_should_not_set_master_volume
    assert_raise(ArgumentError) { session.master_volume = 100 }
    assert_raise(ArgumentError) { session.master_volume = -1 }
  end

  def test_should_set_input_source
    [:phono, :cd, :tuner, :dvd, :hdp, :tv_cbl, :sat, :vcr, :dvr, :v_aux,
      :net_usb, :xm, :hdradio, :dab, :ipod].each do |source|
      transport.expects(:send).with(get_constant(source)).in_sequence(test_sequence)
      transport.expects(:poll_events).returns(input_source_event(source)).in_sequence(test_sequence)
      session.input_source(source)
      assert_equal(get_constant(source).match(/SI(.*)/)[1], session.state.input_source)
    end
  end

  private
  
  def get_constant(source)
    Net::Denon::Constants.const_get("INPUT_SOURCE_#{source.to_s.upcase}".to_sym)
  end

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