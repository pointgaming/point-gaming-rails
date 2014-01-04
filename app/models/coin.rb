class Coin
  include Mongoid::Document

  field :_id, :type => String, :default => proc{ UUIDTools::UUID.random_create.to_s }
  field :wallet_id, :type => String
  field :number_of_coins, :type => Integer

  belongs_to :user

  validates :wallet_id, :presence=>true
  validates :number_of_coins, :presence=>true
end
