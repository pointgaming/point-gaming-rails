class Dispute
  include Mongoid::Document
  include Mongoid::Timestamps
  include Workflow

  OUTCOMES = [:new_match_winner, :rejected, :void_match]

  scope :active, lambda { nin(state: [:cancelled]) }

  field :state, :type => String
  field :outcome, :type => String, default: 'pending'
  field :message_count, :type => Integer, default: 0

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
  belongs_to :match
  belongs_to :winner, :polymorphic => true

  has_many :messages, class_name: 'DisputeMessage'

  validates :match, :presence=>true
  validates :owner, :presence=>true
  validate :message_presence, on: :create
  validate :check_outcome, on: :update
  validate :winner_played_in_match, on: :update

  def mq_exchange
    "Dispute_#{_id}"
  end

  def finalize
    Resque.enqueue ProcessDisputeOutcomeJob, self._id unless outcome === 'rejected'
  end

protected

  def message_presence
    self.errors[:base] << 'Message is required' if messages.length < 1
  end

  def check_outcome
    return unless outcome.present?

    self.errors[:base] << 'Outcome is invalid' unless OUTCOMES.include?(outcome.to_sym)
  end

  def winner_played_in_match
    return if outcome != 'new_match_winner'

    unless [match.player_1, match.player_2].include?(winner)
      self.errors[:base] << 'Winner is invalid'
    end
  end

end
