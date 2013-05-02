class SubscriptionType
  include Mongoid::Document

  field :name, :type => String
  field :sort_order, :type => Integer

  # key/value store for subscription_feature_id => feature_value
  # feature_value is the value offered by the specific subscription for a specific feature
  field :feature_values, :type => Hash, default: {}

  validates :name, presence: true, uniqueness: true

  def value_for_feature(feature)
    feature_values[feature._id.to_s]
  end
end
