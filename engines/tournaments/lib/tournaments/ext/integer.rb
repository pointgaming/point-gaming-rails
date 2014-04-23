class Integer
  def pow2?
    self & (self - 1) == 0
  end
end
