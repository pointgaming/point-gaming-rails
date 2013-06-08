module DateHelpers

  def ldate(date)
    date.strftime('%m/%d/%Y %I:%M %p')
  end

end
