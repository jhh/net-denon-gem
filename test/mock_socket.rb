class MockSocket
  
  include Test::Unit::Assertions
  
  attr_writer(:command, :response)
  
  def initialize
    
  end
  
  def close
    @closed = true
  end
  
  def closed?
    @closed
  end

end