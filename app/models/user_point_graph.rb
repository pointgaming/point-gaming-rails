class UserPointGraph

  attr_accessor :start_datetime, :end_datetime, :data, :max_days

  def initialize(user, max_days = 30)
    self.max_days = max_days
    self.data = build_data(user)
    self.start_datetime = data.first.time
    self.end_datetime = data.last.time
  end

  private

  def build_data(user)
    points = user.point_history.recent.order_by(created_at: :asc).to_a

    add_missing_point_history(points)

    data = []
    points.each do |history|
      data.push UserPointGraphData.new(history.created_at, history.start_balance)
      data.push UserPointGraphData.new(history.created_at, history.end_balance)
    end
    data
  end

  def add_missing_point_history(points)
    add_point_for_today(points)
    add_start_point(points)
  end

  def add_point_for_today(points)
    last_point = points.last
    points.push fake_point(DateTime.now, last_point.end_balance)
  end

  def add_start_point(points)
    first_point = points.first

    if first_point.days_since < max_days
      points.unshift(
        fake_point(DateTime.now - max_days, first_point.start_balance)
      )
    end
  end

  def fake_point(datetime, balance)
    UserPointHistory.new({
      created_at: datetime,
      start_balance: balance,
      end_balance: balance
    })
  end

end
