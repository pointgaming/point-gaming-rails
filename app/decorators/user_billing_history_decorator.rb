class UserBillingHistoryDecorator < Draper::Decorator

  def amount
    h.number_to_currency(model.amount)
  end

end
