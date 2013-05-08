module SubscriptionsHelper
  def term_options(expiration_date)
    expiration_date ||= Date.today
    [1, 2, 3, 6, 12, 24, 36, 48, 60].map{|i| term_option(i, expiration_date) }
  end

  def term_option(number_of_months, expiration_date)
    [term_display_name(number_of_months), 
      number_of_months, 
      {:'data-price' => term_price(number_of_months),
       :'data-expiration-date' => term_expiration_date(number_of_months, expiration_date) }]
  end

  def term_display_name(number_of_months)
    display = number_of_months >= 12 ?
      pluralize((number_of_months / 12), 'Year') :
      pluralize(number_of_months, 'Month')

    "#{display} (#{term_price(number_of_months)})"
  end

  def term_price(number_of_months)
    number_to_currency BigDecimal.new("5") * number_of_months
  end

  def term_expiration_date(number_of_months, current_expiration_date)
    ldate( number_of_months.months.since(current_expiration_date) )
  end

end
