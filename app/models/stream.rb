class Stream
  include Mongoid::Document

  field :name, :type => String, :default => ''
  field :details, :type => String, :default => ''
  field :map, :type => String, :default => ''
  field :betting, :type => Boolean, :default => true
  field :streaming, :type => Boolean, :default => false

  field :viewer_count, :type => Integer, :default => 0

  belongs_to :player_1, :polymorphic => true
  belongs_to :player_2, :polymorphic => true

  belongs_to :game

  has_many :bets
  has_many :collaborators, dependent: :destroy

  validates :name, :presence=>true
  validates :player_1, :presence=>true, :if => :betting_enabled?
  validates :player_2, :presence=>true, :if => :betting_enabled?
  validates :map, :presence=>true, :if => :betting_enabled?
  validates :betting, :presence=>true
  validates :viewer_count, :presence=>true

  def owner
    Collaborator.where(stream_id: self.id, owner: true).first
  end

  def bet_details
    betting ? "Betting Open: #{player_1.playable_name} vs #{player_2.playable_name} on #{map}" : "Betting Closed"
  end

  def player_options
    [[player_1.playable_name, :player_1], [player_2.playable_name, :player_2]]
  end

  attr_writer :player_1_name, :player_2_name
  
  def player_1_name
    player_1 ? player_1.playable_name : read_attribute("player_1_name")
  end

  def player_2_name
    player_2 ? player_2.playable_name : read_attribute("player_2_name")
  end

  def mq_exchange
    "s.#{_id}"
  end

private

  def betting_enabled?
    betting
  end
end
