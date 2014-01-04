class Dispute
  include Mongoid::Document
  include Mongoid::Timestamps
  include Workflow

  REASONS = [:cheating_player, :incorrect_match_outcome]
  OUTCOMES = [:new_match_winner, :rejected, :void_match]

  scope :active, lambda { where(state: :new) }
  scope :available, lambda { nin(state: [:cancelled]) }
  scope :historical, lambda { self.in(state: [:cancelled, :finalized]) }

  field :state, :type => String
  field :reason, :type => String
  field :outcome, :type => String, default: 'pending'
  field :message_count, :type => Integer, default: 0
  field :user_viewer_count, :type => Integer, :default => 0
  field :admin_viewer_count, :type => Integer, :default => 0

  workflow_column :state
  workflow do
    state :new do
      event :cancel, transitions_to: :cancelled
      event :finalize, transitions_to: :finalized
    end 
    state :cancelled
    state :finalized
  end

  belongs_to :owner, class_name: 'User'
  belongs_to :cheater, class_name: 'User'
  belongs_to :match
  belongs_to :winner, :polymorphic => true

  has_many :messages, class_name: 'DisputeMessage'

  embeds_many :match_logs, class_name: 'DisputeMatchLog'

  validates :reason, :presence=>true
  validates :match, :presence=>true
  validates :owner, :presence=>true
  validate :message_presence, on: :create
  validate :check_outcome, on: :update
  validate :check_reason
  validate :winner_played_in_match, on: :update
  validate :check_cheater

  def mq_exchange
    "Dispute_#{_id}"
  end

  def finalize
    if outcome === 'rejected'
      owner.increment_dispute_lost_count!
    else
      owner.increment_dispute_won_count!
      Resque.enqueue ProcessDisputeOutcomeJob, self._id
    end
  end

  def has_user_viewers?
    user_viewer_count > 0
  end

  def has_admin_viewers?
    admin_viewer_count > 0
  end

  def increment_admin_viewer_count!(amount)
    raise TypeError, "Amount must be a Fixnum." unless amount.class.name === 'Fixnum'
    inc(:admin_viewer_count, amount)
  end

  def increment_user_viewer_count!(amount)
    raise TypeError, "Amount must be a Fixnum." unless amount.class.name === 'Fixnum'
    inc(:user_viewer_count, amount)
  end

  def can_be_viewed_by?(user)
    match.includes_participant?(user) || match.includes_bet_participant?(user)
  end

  def due_to_cheating_player?
    reason.try(:to_sym) === :cheating_player
  end

protected

  def message_presence
    self.errors[:base] << 'Message is required' if messages.length < 1
  end

  def check_outcome
    return unless outcome.present?

    self.errors[:base] << 'Outcome is invalid' unless OUTCOMES.include?(outcome.to_sym)
  end

  def check_reason
    return unless reason.present?
    self.errors[:base] << 'Reason is invalid' unless REASONS.include?(reason.to_sym)
  end

  def check_cheater
    if due_to_cheating_player? && !cheater.present?
      self.errors[:cheater_id] << 'is required'
    end
  end

  def winner_played_in_match
    return if outcome != 'new_match_winner'

    unless [match.player_1, match.player_2].include?(winner)
      self.errors[:base] << 'Winner is invalid'
    end
  end

end
