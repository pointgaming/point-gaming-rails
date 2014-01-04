class TeamDecorator < Draper::Decorator

  def points
    h.number_with_delimiter(model.points)
  end

end
