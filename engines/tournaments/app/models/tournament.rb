class Tournament
  include Mongoid::Document
  include Workflow

  cattr_reader :formats, :types

  after_create :trigger_created
  before_validation :set_tournament_slug, on: :create
  after_save :move_to_next_state!

  @@formats = [:single_elimination, :double_elimination, :round_robin]
  @@types = [:open, :invite]

  scope :pending, lambda { where(state: :payment_pending) }
  scope :activated, lambda { where(state: :activated) }
  scope :collaborated, lambda { |user| any_of({ owner_id: user.id }, { collaborators: user.id }) }

  field :name
  field :slug
  field :stream_slug
  field :signup_ends_at, type: DateTime
  field :checkin_hours, type: Integer, default: 1
  field :player_limit, type: Integer, default: 128
  field :format
  field :type
  field :details
  field :state, default: "new"
  field :prizepool, type: Hash, default: {}
  field :prizepool_total, type: BigDecimal, default: BigDecimal.new("0")
  field :player_count, type: Integer, default: 0
  field :sponsor_request_state, default: "not_requested"
  field :collaborators, type: Array, default: []

  # The brackets format here needs to match the format used in the jQuery
  # brackets library. Here"s an example:
  #
  # {
  #   teams: [
  #     ["rapha",       "Cypher" ],
  #     ["ZeRo4",       "zar" ],
  #     ["jochs",       "DaHanG" ],
  #     ["dkt",         "chance" ],
  #     ["sparks",      "evil"],
  #     ["_ash",        "VeT"],
  #     ["apparition",  "whaz"],
  #     ["id_",         "andriiiiii"]
  #   ],
  #   results: [[ /* WINNER BRACKET */
  #     [[3,5], [2,4], [3,6], [2,3], [1,5], [5,3], [7,2], [1,2]],
  #     [[1,2], [3,4], [5,6], [7,8]],
  #     [[9,1], [8,2]],
  #     [[1,3]]
  #   ],[         /* LOSER BRACKET */
  #     [[5,1], [1,2], [3,2], [6,9]],
  #     [[8,2], [1,2], [6,2], [1,3]],
  #     [[1,2], [3,1]],
  #     [[3,0], [1,9]],
  #     [[3,2]],
  #     [[4,2]]
  #   ],[         /* FINALS */
  #     [[3,8], [1,2]],
  #     [[2,1]]
  #   ]]
  # }
  field :brackets, type: Hash, default: {}

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
  belongs_to :owner, class_name: "User"

  has_one :payment

  has_many :sponsors, dependent: :destroy
  has_many :invites,  dependent: :destroy
  embeds_many :players

  validates :name, presence: true, uniqueness: true
  validates :slug, presence: true, uniqueness: true
  validates :signup_ends_at, presence: true
  validates :checkin_hours, presence: true, numericality: { only_integer: true, greater_than: 0, less_than: 4 }
  validates :player_limit, presence: true, numericality: { only_integer: true, greater_than: 0, even: true }
  validates :format, presence: true
  validates :type, presence: true
  validates :game, presence: true
  validates :game_type, presence: true
  validates :details, presence: true
  validate :validate_prizepool
  validate :validate_prizepool_fields

  def status_steps
    StatusStep.steps.map do |step|
      StatusStep.new(tournament: self, step: step)
    end
  end

  def validate_prizepool
    if prizepool_was.present? && prizepool_changed? && prizepool_required? == false
      self.errors[:prizepool] << "can no longer be changed"
    end
  end

  def validate_prizepool_fields
    return unless prizepool.present?
    prizepool.each do |placement, prize|
      if prize.present? && prize !~ /^\d+(\.\d{1,2})?$/
        self.errors[:base] << "#{ActiveSupport::Inflector.ordinalize(placement)} must be numeric"
      end
    end
  end

  def signup_open?
    signup_ends_at >= DateTime.now
  end

  def started?
    !signup_open?
  end

  def checkin_date
    signup_ends_at - checkin_hours.hours
  end

  def checkin_open?
    now = DateTime.now
    now > checkin_date && now < signup_ends_at
  end

  def checkin_open_for?(user)
    checkin_open? && signed_up?(user)
  end

  def checked_in?(user)
    players.where(user: user, :checked_in_at.ne => nil).exists?
  end

  def signed_up?(user)
    players.where(user: user).exists?
  end

  def increment_player_count(amount = 1)
    inc(:player_count, amount)
  end

  def to_param
    slug
  end

  def move_to_next_state!
    prizepool_submitted! if prizepool.present? && prizepool_required?
  end

  # This is just a convenience method for development/console use.
  def report_scores_for(username, mine, his)
    players.find_by(username: username).report_scores!(mine, his)
  end

  def player_for_user(user)
    players.find_by(user_id: user.id)
  end

  def generate_brackets!
    self.brackets = { "teams" => [], "results" => [] }

    # Split up players and seeds
    clean_seeds!

    seeds = self.players.desc(:seed).to_a
    save and return unless seeds.present?

    # Add BYEs if we have n players where n is not a power of 2
    seeds << "BYE" while seeds.count & (seeds.count - 1) != 0

    # Perform the seeding
    bracket_list = seeds.clone
    slice = 1

    while slice < bracket_list.length / 2
      temp = bracket_list
      bracket_list = []

      while temp.length > 0
        bracket_list.concat(temp.slice!(0, slice)) rescue nil
        bracket_list.concat(temp.slice!(-slice, slice)) rescue nil
      end

      slice *= 2
    end

    bracket_list.each_slice(2).to_a.each do |pair|
      self.brackets["teams"] << [(pair[0].id rescue "BYE"), (pair[1].id rescue "BYE")]
    end

    # Go through and set up the first round for the winners, losers, finals
    self.brackets["results"] = [
      [Array.new(self.brackets["teams"].count)      { [] }],  # winners
      [Array.new(self.brackets["teams"].count / 2)  { [] }],  # losers
      [[nil, nil], [nil]]
    ]

    # Set up all subsequent rounds as well, to avoid nil errors
    Math.log2(self.brackets["teams"].count).to_i.times do
      self.brackets["results"][0] << []
    end

    # Number of losers bracket rounds
    (2 * (Math.log2(self.brackets["teams"].count).to_i - 1)).times do
      self.brackets["results"][1] << []
    end

    # Always 2 rounds in the finals
    self.brackets["results"][2] = [[], []]

    save

    # If there are any BYEs, have the other player automatically report a win.
    self.brackets["teams"].each do |pair|
      player = nil

      if pair[0] == "BYE" && pair[1] != "BYE"
        player = self.players.find(pair[1])
      elsif pair[1] == "BYE" && pair[0] != "BYE"
        player = self.players.find(pair[0])
      end

      player.report_scores!(1, 0) if player
    end
  end

  def prizepool_submitted
    if !prizepool.present? || prizepool.values.all? {|item| !item.present?}
      self.errors[:prizepool] << "is required"
      halt "Prizepool is required"
    end
  end

  def payment_submitted
    unless payment.present? && payment.valid?
      self.errors[:payment] << "is required"
      halt "Payment is required"
    end
  end

  def parse_datetime(string)
    return nil unless string.present?
    ["DateTime", "Date"].include?(string.class.name) ? string : Chronic.parse(string, time_class: Time.zone)
  end

  def signup_ends_at=(value)
    write_attribute(:signup_ends_at, parse_datetime(value))
  end

  def prizepool=(value)
    write_attribute(:prizepool, value.reject { |k, v| v.blank? })

    update_prizepool_total
  end

  def prize_pool_size
    player_limit / 2
  end

  def trigger_created
    created!
  end

  def update_prizepool_total
    self.prizepool_total = prizepool.values.select { |val| val.numeric? }.map { |val| BigDecimal.new(val) }.reduce(:+) || BigDecimal.new("0")
  end

  def set_tournament_slug
    # We want to remove all non-word charcters, reduce multiple consecutive
    # spaces down to a single space, and replace the spaces with dashes.
    self.slug = self.name.to_s.downcase.gsub(/[^\w\s]+/i, "").gsub(/\s+/, "-")
  end

  def clean_seeds!
    if seeds.present?
      dead = []
      seeds.each { |seed| dead << seed unless players.where(_id: seed).exists? }

      if dead.present?
        seeds.delete_if { |seed| dead.include?(seed) }
        save
      end
    end

    self.seeds = players.map { |p| p.id.to_s }.shuffle unless seeds.present?
  end
end
