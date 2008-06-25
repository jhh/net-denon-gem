require 'socket'
require 'timeout'

module Net; module Denon
  
  class Transport
    include Loggable
    
    # The standard telnet port, will be used unless specified in options
    DEFAULT_PORT = 23
    
    # The IP address that was passed to constructor.
    attr_reader :host
    
    # The port connected to. Defaults to DEFAULT_PORT.
    attr_reader :port
    
    # The underlying socket object being used to communicate with the
    # receiver.
    attr_reader :socket
    
    # The options passed to constructor.
    attr_reader :options

    # Instantiates a new Transport object used to communicate with the
    # receiver. Options include:
    #  port:: the port to connect to, defaults to DEFAULT_PORT.
    #  logger:: the logger to use
    #  proxy:: a proxy class for TCPSocket, used for testing
    #  timeout:: amount of time to wait for connection, defaults to no timeout
    def initialize(host, options={})
      self.logger = options[:logger]
      @host       = host
      @port       = options[:port] || DEFAULT_PORT
      @options    = options
      
      debug { "establishing connection to #{@host}:#{@port}" }
      factory = options[:proxy] || TCPSocket
      @socket = Timeout::timeout(options[:timeout] || 0) { factory.open(@host, @port) }

      debug { "connection established" }
    end
    
    # Closes the connection to the receiver.
    def close
      socket.close
    end
    
    # Tries to read the next event from the socket.  If mode is :nonblock (the
    # default), this will not block and will return nil if there are no events
    # waiting to be read.
    def poll_event(mode=:nonblock)
    end
      
    end
  end
  
end