class Order
  include Mongoid::Document
  include Mongoid::Timestamps

  field :item_total, type: BigDecimal
  field :tax, type: BigDecimal, default: BigDecimal.new("0.00")
  field :total, type: BigDecimal
  field :stripe_charge_id, type: String

  belongs_to :user

  embeds_many :items, class_name: 'OrderItem'

  validates :user, presence: true

  def add_item(item)
    self.items << item
    update_totals
  end

  def update_totals
    calculate_item_total
    calculate_total
  end

  def calculate_item_total
    self.item_total = items.all.map(&:total).reduce(:+)
  end

  def calculate_total
    self.total = item_total + tax
  end

  def description
    line_items = []
    items.each do |item|
      line_items << item.description
    end
    line_items.join("<br />")
  end
end
