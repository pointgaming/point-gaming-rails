class Tournament
  include Mongoid::Document
  include Workflow

  after_create :trigger_created
  after_save :move_to_next_state!

  FORMATS = [:single_elimination, :double_elimination, :round_robin]
  TYPES = [:open, :invite, :mixed]

  field :name
  field :slug
  field :start_datetime, type: DateTime
  field :signup_start_datetime, type: DateTime
  field :signup_end_datetime, type: DateTime
  field :player_limit, type: Integer, default: 128
  field :format
  field :type
  field :maps
  field :details
  field :state, default: 'new'
  field :prizepool, type: Hash, default: {}
  field :prizepool_total, type: BigDecimal, default: BigDecimal.new("0")
  field :player_count, type: Integer, default: 0
  field :sponsor_request_state, default: 'not_requested'

  workflow_column :state
  workflow do
    state :new do
      event :created, transitions_to: :prizepool_required
    end 
    state :prizepool_required do
      event :prizepool_submitted, transitions_to: :payment_required
    end 
    state :payment_required do
      event :payment_submitted, transitions_to: :payment_pending
    end
    state :payment_pending do
      event :payment_approved, transitions_to: :activated
      event :payment_denied, transitions_to: :payment_required
    end
    state :activated
  end

  belongs_to :game
  belongs_to :game_type
  belongs_to :sponsor_request

  has_many :collaborators, dependent: :destroy, class_name: 'TournamentCollaborator'
  has_many :sponsors, dependent: :destroy, class_name: 'TournamentSponsor'

  validates :name, presence: true, uniqueness: true
  validates :slug, presence: true, uniqueness: true
  validates :signup_start_datetime, presence: true
  validates :signup_end_datetime, presence: true
  validates :start_datetime, presence: true
  validates :player_limit, presence: true, numericality: {only_integer: true, greater_than: 0, even: true}
  validates :format, presence: true
  validates :type, presence: true
  validates :game, presence: true
  validates :game_type, presence: true
  validates :maps, presence: true
  validates :details, presence: true
  validate :validate_prizepool
  validate :validate_prizepool_fields

  def validate_prizepool
    if prizepool_was.present? && prizepool_changed? && prizepool_required? === false
      self.errors[:prizepool] << "can no longer be changed"
    end
  end

  def validate_prizepool_fields
    return unless prizepool.present?
    prizepool.each do |placement, prize|
      if prize.present? && !(prize =~ /^\d+(\.\d{1,2})?$/)
        self.errors[:base] << "#{ActiveSupport::Inflector.ordinalize(placement)} must be numeric"
      end
    end
  end

  def owner
    collaborators.ownership.first.try(:user)
  end

  def destroyable_by_user?(user)
    collaborators.ownership.for_user(user).exists?
  end

  def editable_by_user?(user)
    collaborators.for_user(user).exists?
  end

  def move_to_next_state!
    prizepool_submitted! if prizepool.present? && prizepool_required?
  end

  def prizepool_submitted
    if !prizepool.present? || prizepool.values.all? {|item| !item.present?}
      self.errors[:prizepool] << "is required"
      halt 'Prizepool is required'
    end
  end

  def parse_datetime(string)
    return nil unless string.present?
    string = ["DateTime", "Date"].include?(string.class.name) ? string : DateTime.strptime(string, '%m/%d/%Y %I:%M %p')
    string
  end

  def start_datetime=(value)
    write_attribute(:start_datetime, parse_datetime(value))
  end

  def signup_start_datetime=(value)
    write_attribute(:signup_start_datetime, parse_datetime(value))
  end

  def signup_end_datetime=(value)
    write_attribute(:signup_end_datetime, parse_datetime(value))
  end

  def formats
    FORMATS
  end

  def types
    TYPES
  end

  def prize_pool_size
    player_limit / 2
  end

  def trigger_created
    created!
  end

  def update_prizepool_total
    self.prizepool_total = prizepool.values.select { |val| val.numeric? }
      .map{ |val| BigDecimal.new(val) }.reduce(:+) || BigDecimal.new("0")
  end

end
