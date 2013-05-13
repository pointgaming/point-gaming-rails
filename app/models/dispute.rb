class Dispute
  include Mongoid::Document
  include Mongoid::Timestamps
  include Workflow

  scope :active, lambda { nin(state: [:finalized, :cancelled]) }

  field :state, :type => String
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

  has_many :messages, class_name: 'DisputeMessage'

  validates :match, :presence=>true
  validates :owner, :presence=>true
  validate :message_presence, on: :create

  def mq_exchange
    "Dispute_#{_id}"
  end

protected

  def message_presence
    self.errors[:base] << 'Message is required' if messages.length < 1
  end

end
