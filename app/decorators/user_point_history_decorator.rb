class UserPointHistoryDecorator < Draper::Decorator

  def amount
    h.number_with_delimiter(model.amount)
  end

end
