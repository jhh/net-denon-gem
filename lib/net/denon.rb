require 'net/denon/session'

module Net ; module Denon

  # A convenience method for starting a new Denon session. See
  # Net::Denon::Session.
  def start(host, options)
    Net::Denon::Session.new(host, options)
  end
  module_function :start
  
end ; end