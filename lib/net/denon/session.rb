require 'socket'
require 'timeout'
require 'net/denon/status'
require 'net/denon/transport'

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
  
    def query
      send_command "PW?"
      send_command "MU?"
      send_command "MV?"
      send_command "SI?"
      send_command "ZM?"
      # send_command "CV?"
    end
    
    def on
      send_command "PW?"
      check_status
      send_command "PWON" unless state.on?
    end
    
    def standby
      send_command "PW?"
      check_status
      send_command "PWSTANDBY" unless state.standby?
    end
    
    def mute
      send_command "MU?"
      check_status
      send_command "MUON" unless state.mute?
    end
    
    def unmute
      send_command "MU?"
      check_status
      send_command "MUOFF" if state.mute?
    end
    
    def master_volume=(volume)
      v = volume.to_i
      if (v > 0 && v < 99) then
        send_command("MV#{v}")
      end
    end
    
    protected
    
    def log(message)
      @log.write(message) if @options.has_key?(:log)
    end
    
    # FIXME: move send_command into Transport class
    def send_command(string)
      string += "\r"
      length = string.length
      while 0 < length
        IO::select(nil, [transport.socket])
        length -= transport.socket.syswrite(string[-length..-1])
      end
      sleep 0.1
      check_status
    end
    
    def check_status
      state.update(transport.poll_events)
    end
  
  end

end ; end