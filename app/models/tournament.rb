class Tournament
  include Mongoid::Document

  SPONSOR_REQUEST_STATUSES = [:new, :requested, :declined, :accepted]
  PRIZEPOOL_STATUSES = [:deposit_required, :deposit_pending, :configure_prizepool, :prizepool_finalized]
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
  field :prizepool, type: Hash, default: {}
  field :prizepool_status, default: 'deposit_required'
  field :prizepool_total, type: BigDecimal, default: BigDecimal.new("0")
  field :player_count, type: Integer, default: 0
  field :sponsor_request_status, default: 'new'

  belongs_to :game
  belongs_to :game_type

  has_many :deposits, class_name: 'TournamentDeposit'
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

  def start_datetime=(value)
    write_attribute(:start_datetime, Date.strptime(value, '%m/%d/%Y %I:%M %p')) if value.present?
  end

  def signup_start_datetime=(value)
    write_attribute(:signup_start_datetime, Date.strptime(value, '%m/%d/%Y %I:%M %p')) if value.present?
  end

  def signup_end_datetime=(value)
    write_attribute(:signup_end_datetime, Date.strptime(value, '%m/%d/%Y %I:%M %p')) if value.present?
  end

  def owner
    collaborators.where(owner: true).first
  end

  def formats
    FORMATS
  end

  def types
    TYPES
  end

end
