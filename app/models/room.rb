class Room
  include Mongoid::Document

  field :description, :type => String, :default => ''
  field :hidden, :type => Boolean, :default => false
  field :player_limit, :type => Integer, :default => 99

  field :player_count, :type => Integer, :default => 0

  belongs_to :game

  validates :hidden, :presence=>true
  validates :player_limit, :presence=>true

  validates :player_count, :presence=>true
end
