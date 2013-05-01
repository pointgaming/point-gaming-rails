class Match
  include Mongoid::Document
  include Mongoid::Timestamps
  include Workflow
  include MatchesHelper

  before_save :calculate_match_hash, :if => :match_criteria_changed?

  after_create :publish_created
  after_update :publish_updated
  after_update :void_bets

  field :betting, :type => Boolean, :default => true
  field :map, :type => String, :default => ''
  field :state, :type => String
  field :match_hash, :type => String
  field :default_offerer_odds, :type => String

  workflow_column :state
  workflow do
    state :new do
      event :start, transition_to: :started
      event :cancel, transitions_to: :cancelled
    end 
    state :started do
      event :finalize, transitions_to: :finalized
      event :cancel, transitions_to: :cancelled
    end 
    state :cancelled
    state :finalized
  end

  belongs_to :game
  belongs_to :room, :polymorphic => true
  belongs_to :player_1, :polymorphic => true
  belongs_to :player_2, :polymorphic => true
  belongs_to :winner, :polymorphic => true

  has_many :bets

  validates :player_1, :presence=>true
  validates :player_2, :presence=>true
  validates :map, :presence=>true
  validates :game, :presence=>true
  validate :check_winner
  validate :check_default_offerer_odds

  attr_writer :player_1_name, :player_2_name
  
  def player_1_name
    player_1 ? player_1.display_name : read_attribute("player_1_name")
  end

  def player_2_name
    player_2 ? player_2.display_name : read_attribute("player_2_name")
  end

  def player_options
    [[player_1.display_name, player_1._id, {:'data-type' => player_1.class.name}],
     [player_2.display_name, player_2._id, {:'data-type' => player_2.class.name}]]
  end

  def start
    Resque.enqueue VoidUnacceptedBetsJob, self._id
  end

  def cancel
    if self.room.present?
      self.room.match = nil;
      self.room.save
    end

    Resque.enqueue FinalizeBetsJob, self._id
  end

  def finalize
    self.room.match = nil;
    self.room.save

    Resque.enqueue FinalizeBetsJob, self._id
  end

private

  def check_default_offerer_odds
    errors.add(:default_offerer_odds, "is required") if self.room_type === 'GameRoom' && self.default_offerer_odds.blank?
  end

  def check_winner
    if self.state != 'new'
      if self.winner.present?
        errors.add(:winner_id, "is invalid") unless [self.player_1, self.player_2].include?(self.winner)
      else
        errors.add(:winner_id, "is required")
      end
    end
  end

  def calculate_match_hash
    data = match_criteria.map{|column| self.send(column)}
    self.match_hash = Digest::MD5.hexdigest( data.join(':') )
  end

  def match_criteria
    ['betting', 'player_1_id', 'player_1_type', 'player_2_id', 'player_2_type']
  end

  def match_criteria_changed?
    !(self.changed & match_criteria).empty?
  end

  def publish_created
    return unless self.room.present?
    BunnyClient.instance.publish_fanout("c.#{self.room.mq_exchange}", {
      :action => 'Match.new',
      :data => {
        :match => self,
        :match_details => match_details(self)
      }
    }.to_json)
  end

  def publish_updated
    return unless self.room.present?
    BunnyClient.instance.publish_fanout("c.#{self.room.mq_exchange}", {
      :action => 'Match.update',
      :data => {
        :match => self,
        :match_details => match_details(self)
      }
    }.to_json)
  end

  def void_bets
    Resque.enqueue(VoidBetsJob, self._id) if self.state === 'new' && match_hash_changed?
  end

end
