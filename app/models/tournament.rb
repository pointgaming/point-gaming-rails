class Tournament
  include Mongoid::Document

  field :start_datetime, :type => DateTime
  field :game_type, :type => String, :default => ''
  field :prize_pool, :type => String, :default => ''
  field :player_limit, :type => Integer, :default => 99

  field :player_count, :type => Integer, :default => 0

  belongs_to :game

  validates :start_datetime, :presence=>true
  validates :game_type, :presence=>true
  validates :prize_pool, :presence=>true
  validates :player_limit, :presence=>true

  validates :player_count, :presence=>true
end
