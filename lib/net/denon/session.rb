require 'socket'
require 'timeout'
require 'net/denon/state'
require 'net/denon/transport'
require 'net/denon/constants'

module Net ; module Denon

  #
  # == Net::Denon::Session
  #
  # Provides DENON AVR control protocol client functionality.
  #
  # == Overview
  #
  # The DENON AVR control protocol allows a client to send commands to a Denon
  # AVR reciever via its embedded telnet server. This library currently
  # implements version 5.1.0_a for model AVR-4308.
  #
  # == Examples
  #
  # === Log in and send a command
  #
  #   denon = Net::Denon.new("10.0.1.201")
  #   denon.power_on
  #   denon.close
  #
  # == References
  #
  # This library implements the DENON AVR control protocol as documented by
  # Denon at:
  # http://usa.denon.com/AVR-4308CISerialProtocol_Ver5.1.0a.pdf
  #
  class Session
    include Constants
    
    # The underlying transport.
    attr_reader :transport
    
    # The current state of the receiver
    attr_reader :state
  
    # Creates a new Net::Denon object and connects it to the telnet port (23) of
    # the Denon receiver on the named host.
    #
    # +options+ is a hash of options.  The following example lists all options
    # and their default values.
    #
    #   denon = Net::Denon::new(
    #     :host       => "10.0.1.201", # default: nil
    #     :port       => 23,           # default: 23
    #     :wait_time  => 0.2,          # default: 0.2 sec
    #     :timeout    => 1,            # default: 1 sec
    #     :log        => "debug.txt",  # default: nil (no output)
    #     :proxy      => proxy,        # default: nil
    #     )
    #
    # The options have the following meanings:
    #
    # host:: the hostname or IP address to connect to, as a String.
    #
    # port:: the port to connect to; defaults to 23.
    #
    # wait_time:: the amount of time to wait for a response after sending
    #             a command; default is 0.2 sec.
    #
    # timeout:: the amount of time to wait trying to connect.  Exceeding
    #           this timeout value causes a Timeout::Error to be raised.
    #           Defaults to 1 sec.
    #
    # log:: commands and output will be dumped to this file; defaults
    #       to no output.
    #
    # proxy:: a proxy object to be used instead of opening a direct connection
    #         to the host.
    #
    def initialize(host, options)
      @transport = Net::Denon::Transport.new(host, options)
      @state = Net::Denon::Status::new
    end
  
    # Disconnects from the server.
    def close
      transport.close
    end
  
    def query!
      send_command POWER_STATUS
      send_command MUTE_STATUS
      send_command MASTER_VOLUME_STATUS
      send_command INPUT_SOURCE_STATUS
    end
    
    def on!
      send_command POWER_STATUS
      send_command POWER_ON unless state.on?
    end
    
    def standby!
      send_command POWER_STATUS
      send_command POWER_STANDBY unless state.standby?
    end
    
    def mute!
      send_command MUTE_STATUS
      send_command MUTE_ON unless state.mute?
    end
    
    def unmute!
      send_command MUTE_STATUS
      send_command MUTE_OFF if state.mute?
    end
    
    def master_volume=(volume)
      v = volume.to_i
      if (v > 0 && v < 99) then
        send_command(MASTER_VOLUME_SET + v)
      end
    end
    
    def send_command(command)
      transport.send command
      check_status
    end

    protected
    
    def log(message)
      @log.write(message) if @options.has_key?(:log)
    end
    
    def check_status
      state.update(transport.poll_events)
    end
  
  end

end ; end