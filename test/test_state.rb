require 'common'
require 'net/denon/state'
require 'net/denon/constants'

class TestState < Test::Unit::TestCase
  include Net::Denon::Constants
  
  def setup
    @ds = Net::Denon::State.new
  end

  def test_initialize
    assert_nil(@ds.standby?)
    assert_nil(@ds.mute?)
  end
  
  def test_should_update_power
    @ds.update(POWER_STANDBY + CR)
    assert(@ds.standby?)
    assert(!@ds.on?)
    
    @ds.update(POWER_STANDBY + CR + POWER_ON + CR)
    assert(@ds.on?)
    assert(!@ds.standby?)
    
    @ds.update(POWER_ON + CR + POWER_STANDBY + CR)
    assert(!@ds.on?)
    
  end
  
  def test_should_update_master_volume
    @ds.update(MASTER_VOLUME_SET + '00' + CR)
    assert_equal(0, @ds.master_volume)
    @ds.update(MASTER_VOLUME_SET + '10' + CR)
    assert_equal(10, @ds.master_volume)
    @ds.update(MASTER_VOLUME_SET + '00' + CR + MASTER_VOLUME_MAX + '98' + CR)
    assert_equal(98, @ds.master_volume_max)
    assert_equal(00, @ds.master_volume)
    @ds.update(MASTER_VOLUME_SET + '95' + CR + MASTER_VOLUME_MAX + '96' + CR +
      MASTER_VOLUME_SET + '97' + CR + MASTER_VOLUME_MAX + '99' + CR)
    assert_equal(97, @ds.master_volume)
    assert_equal(99, @ds.master_volume_max)
  end
  
  def test_should_update_mute
    @ds.update(MUTE_ON + CR)
    assert(@ds.mute?)
  end
  
  def test_should_update_multiple
    @ds.update(MUTE_OFF + CR + MASTER_VOLUME_SET + '73' + CR)
    assert_equal(73, @ds.master_volume)
    assert(!@ds.mute?)
    @ds.update(MASTER_VOLUME_SET + '21' + CR + MUTE_ON + CR)
    assert_equal(21, @ds.master_volume)
    assert(@ds.mute?)
  end
  
  def test_should_update_channel_volume
    @ds.update("CVFL 23\r")
    assert_equal(23, @ds.channel_volume[:front_left])
    @ds.update("CVFR 24\r")
    assert_equal(24, @ds.channel_volume[:front_right])
    @ds.update("CVC 25\r")
    assert_equal(25, @ds.channel_volume[:center])
    @ds.update("CVSW 26\r")
    assert_equal(26, @ds.channel_volume[:subwoofer])
    @ds.update("CVSL 27\r")
    assert_equal(27, @ds.channel_volume[:surround_left])
    @ds.update("CVSR 28\r")
    assert_equal(28, @ds.channel_volume[:surround_right])
    @ds.update("CVSBL 29\r")
    assert_equal(29, @ds.channel_volume[:surround_back_left])
    @ds.update("CVSBR 30\r")
    assert_equal(30, @ds.channel_volume[:surround_back_right])
    @ds.update("CVSB 31\r")
    assert_equal(31, @ds.channel_volume[:surround_back])
    @ds.update("CVFL 32\rCVFR 33\rCVC 34\r")
    assert_equal(32, @ds.channel_volume[:front_left])
    assert_equal(33, @ds.channel_volume[:front_right])
    assert_equal(34, @ds.channel_volume[:center])
  
  end

  def test_should_update_input_source
    @ds.update(INPUT_SOURCE_PHONO + CR)
    assert_equal("PHONO", @ds.input_source)
    @ds.update(INPUT_SOURCE_NET_USB + CR)
    assert_equal("NET/USB", @ds.input_source)
  end
  
  def test_should_update_main_zone
    @ds.update("ZMON\r")
    assert(@ds.main_zone_on?)
    @ds.update("ZMON\rZMOFF\r")
    assert(!@ds.main_zone_on?)
    
  end
  
  def test_should_update_record_source
    @ds.update("SRPHONO\r")
    assert_equal("PHONO", @ds.record_source)
    @ds.update("SRNET/USB\r")
    assert_equal("NET/USB", @ds.record_source)
  end
  
end