$LOAD_PATH.unshift "#{File.dirname(__FILE__)}/../lib"
require 'rubygems'
require 'test/unit'
require 'mocha'
require 'net/denon/constants'
require 'net/denon/loggable'

include Net::Denon::Constants

def power_event(state=on)
  (state ? POWER_ON : POWER_STANDBY) + CR
end

def mute_event(state=on)
  (state ? MUTE_ON : MUTE_OFF) + CR
end

def volume_event(vol, max)
  MASTER_VOLUME_SET + vol.to_s + CR + MASTER_VOLUME_MAX + max.to_s + CR
end

def input_source_event(source)
  case source
  when :phono
    INPUT_SOURCE_PHONO + CR
  when :cd
    INPUT_SOURCE_CD + CR
  when :tuner
    INPUT_SOURCE_TUNER + CR
  when :dvd
    INPUT_SOURCE_DVD + CR
  when :hdp
    INPUT_SOURCE_HDP + CR
  when :tv_cbl
    INPUT_SOURCE_TV_CBL + CR
  when :sat
    INPUT_SOURCE_SAT + CR
  when :vcr
    INPUT_SOURCE_VCR + CR
  when :dvr
    INPUT_SOURCE_DVR + CR
  when :v_aux
    INPUT_SOURCE_V_AUX + CR
  when :net_usb
    INPUT_SOURCE_NET_USB + CR
  when :xm
    INPUT_SOURCE_XM + CR
  when :hdradio
    INPUT_SOURCE_HDRADIO + CR
  when :dab
    INPUT_SOURCE_DAB + CR
  when :ipod
    INPUT_SOURCE_IPOD + CR
  else
    raise ArgumentError.new("input source not recognized: #{source}")
  end

end

def volume_command(vol)
  MASTER_VOLUME_SET + vol.to_s
end

