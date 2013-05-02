class SubscriptionFeature
  include Mongoid::Document

  field :name, :type => String
  field :sort_order, :type => Integer

  validates :name, presence: true, uniqueness: true

end
