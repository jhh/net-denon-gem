require 'socket'
require 'timeout'
require 'net/denon/loggable'

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

    # Sends a command string to the receiver.
    def send(string)
      string += "\r"
      length = string.length
      while 0 < length
        IO::select(nil, [socket])
        length -= socket.syswrite(string[-length..-1])
      end
    end
    
    # Tries to read the next event(s) from the socket.
    def poll_events
      buffer = ''
      line = "\r"

      until(line[-1] == 13 and not IO::select([socket], nil, nil, @options[:wait_time] || 0.1))
        buffer = socket.readpartial(1024)
        line += buffer
      end
      line
    end
      
  end
end ; end