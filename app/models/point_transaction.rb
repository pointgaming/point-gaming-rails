# We should track any 'new' points that enter the system using this model
#
# Points may enter the system in the following ways:
#  - A user purchases a subscription which gives him points over time
#  - A user purchases an item on the PointGaming store, receiving a small number of points
#  - A user mines bitcoins and is given points for his work
class PointTransaction
  include Mongoid::Document
  include Mongoid::Timestamps

  field :amount, type: Integer

  belongs_to :user

  validates :amount, presence: true
  validates :user, presence: true
end
