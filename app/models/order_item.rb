class OrderItem
  include Mongoid::Document

  field :description, type: String
  field :quantity, type: Integer
  field :price, type: BigDecimal

  belongs_to :item, polymorphic: true

  embedded_in :order

  def total
    price * quantity
  end

end
