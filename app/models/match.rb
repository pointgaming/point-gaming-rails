class Match
  include Mongoid::Document
  include Mongoid::Timestamps
  include Matches::MatchPublication
  include Matches::Disputation
  include Services::Resque
  include Workflow

  before_save :calculate_match_hash, :if => :match_criteria_changed?

  after_update :void_bets

  field :map, :type => String, :default => ''
  field :state, :type => String
  field :match_hash, :type => String
  field :default_offerer_odds, :type => String
  field :finalized_at, :type => DateTime
  field :team_size, :type => Integer

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
    state :finalized do
      event :dispute_finalized, transition_to: :disputed
    end
    state :disputed
  end

  belongs_to :game
  belongs_to :room, :polymorphic => true
  belongs_to :player_1, :polymorphic => true
  belongs_to :player_2, :polymorphic => true
  belongs_to :winner, :polymorphic => true

  has_many :bets

  validates :player_1, :presence=>true
  validates :player_2, :presence=>true, :if => :requires_second_player?
  validates :map, :presence=>true
  validates :game, :presence=>true
  validates :team_size, :presence=>true, :if => :is_team_vs_mode?
  validate :check_winner
  validate :check_default_offerer_odds
  validate :player_1_and_player_2_validation

  attr_accessor :void_match
  attr_writer :player_1_name, :player_2_name

  def loser
    return nil unless winner.present?
    winner === player_1 ? player_2 : player_1
  end

  def player_1_name
    player_1 ? player_1.display_name : read_attribute("player_1_name")
  end

  def player_2_name
    player_2 ? player_2.display_name : read_attribute("player_2_name")
  end

  def player_options
    [
      [player_1_name, :player_1],
      [player_2_name, :player_2]
    ]
  end  

  def is_team_vs_mode?
    player_1_type == "Team" && (player_2_type.nil? || player_2_type == "Team")
  end

  def is_player_vs_mode?
    player_1_type == "User" && (player_2_type.nil? || player_2_type == "User")
  end  

  def requires_second_player?
    !(is_new_state? && is_game_room_match?)
  end

  def is_game_room_match?
    room && room.is_a?(GameRoom) ? true : false
  end

  def is_new_state?
    state.nil? || state == 'new'
  end

  def can_user_assign_cheater?(user)
    participant = find_participant_for_user(user)
    if participant.class.name === "User"
      return true
    elsif participant.class.name === "TeamMember"
      return ["Leader", "Manager"].include?(participant.rank)
    end
    false
  end

  def find_participant_for_user(user)
    return player_1 if user === player_1
    return player_2 if user === player_2
    if player_1_type === "Team"
      team_member = user.team_members.for_team(player_1).first
      return team_member if team_member.present?
    end
    if player_2_type === "Team"
      team_member = user.team_members.for_team(player_2).first
      return team_member if team_member.present?
    end
  end

  def includes_participant?(player)
    (player_1 === player || (player_1_type === "Team" && player.team_member?(player_1))) ||
       (player_2 === player || (player_2_type === "Team" && player.team_member?(player_2)))
  end

  def includes_bet_participant?(user)
    bets.for_user(user).exists?
  end

  def all_users(except_user=nil)
    users = (users_for_player(player_1) + users_for_player(player_2)).uniq
    users.reject!{|user| user === except_user} if except_user.present?
    users
  end

  def users_for_player(player)
    users = []
    if player.class.name === "Team"
      users.push *player.members.all.map(&:user)
    elsif player.class.name === "User"
      users.push player
    end
    users
  end

  def start
    Resque.enqueue VoidUnacceptedBetsJob, self._id if resque_available?
  end

  def cancel
    if self.room.present?
      self.room.match = nil;
      self.room.save
    end

    Resque.enqueue FinalizeBetsJob, self._id if resque_available?
  end

  def finalize
    self.finalized_at = DateTime.now
    self.room.match = nil;
    self.room.save

    Resque.enqueue FinalizeBetsJob, self._id if resque_available?
  end

  def report_winner!(user)
    self.winner = if user.id == player_1_id || user.id == player_2_id
      user
    elsif user.team_id == player_1_id || user.team_id == player_2_id
      user.team
    end
    save && finalize!
  end

  private

    def check_default_offerer_odds
      errors.add(:default_offerer_odds, "is required") if self.room_type === 'GameRoom' && self.default_offerer_odds.blank?
    end

    def player_1_and_player_2_validation
      if (player_1 === player_2)
        self.errors[:base] << "#{self.class.human_attribute_name(:player_1)} and #{self.class.human_attribute_name(:player_2)} cannot be the same"
      end
    end

    def check_winner
      if self.state === 'started'
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
      ['player_1_id', 'player_1_type', 'player_2_id', 'player_2_type']
    end

    def match_criteria_changed?
      !(self.changed & match_criteria).empty?
    end

    def should_void_bets?
      self.state === 'new' && match_hash_changed? ? true : false
    end

    def void_bets
      if resque_available? && should_void_bets?
        Resque.enqueue(VoidBetsJob, self._id) 
      end
    end
end
