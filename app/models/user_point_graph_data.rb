class UserPointGraphData

  attr_accessor :time, :value

  def initialize(time, value)
    self.time = time
    self.value = value
  end

  def time=(value)
    @time = value.to_i * 1000
  end

end
