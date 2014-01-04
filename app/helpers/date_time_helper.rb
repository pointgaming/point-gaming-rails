module DateTimeHelper

  def time_zone_offset(time_zone)
    ActiveSupport::TimeZone.new(time_zone || "Central Time (US & Canada)").now.formatted_offset
  end

  def ldate(dt, options = {})
    dt ? l(dt, options) : ''
  end

end
