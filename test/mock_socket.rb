class MockSocket
  
  def initialize(expected = '')
    @expected = expected
    @closed = false
  end
  
  def close
    @closed = true
  end
  
  def closed?
    @closed
  end

end