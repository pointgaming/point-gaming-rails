class Tournament
  include Mongoid::Document
  include Workflow

  cattr_reader :formats, :types

  after_create :trigger_created
  before_validation :set_tournament_slug, on: :create
  after_save :move_to_next_state!

  @@formats = [:single_elimination, :double_elimination]
  @@types = [:open, :invite]

  scope :pending, lambda { where(state: :payment_pending) }
  scope :activated, lambda { where(state: :activated) }
  scope :collaborated, lambda { |user| any_of({ owner_id: user.id }, { collaborators: user.id }) }

  field :name
  field :slug
  field :stream_slug
  field :starts_at, type: DateTime
  field :checkin_hours, type: Integer, default: 1
  field :player_limit, type: Integer, default: 128
  field :format
  field :type
  field :details, default: I18n.t("tournament.form.details")
  field :state, default: "new"
  field :prizepool, type: Hash, default: {}
  field :prizepool_total, type: BigDecimal, default: BigDecimal.new("0")
  field :sponsor_request_state, default: "not_requested"
  field :collaborators, type: Array, default: []
  field :has_groupstage, type: Boolean
  field :invite_only, type: Boolean

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

  has_many :sponsors, dependent: :destroy
  has_many :invites,  dependent: :destroy
  embeds_many :players
  embeds_one :payment

  validates :name, presence: true, uniqueness: true
  validates :slug, presence: true, uniqueness: true
  validates :starts_at, presence: true
  validates :checkin_hours, presence: true, numericality: { only_integer: true, greater_than: 0, less_than: 4 }
  validates :player_limit, presence: true, numericality: { only_integer: true, greater_than: 0, even: true }
  validates :format, presence: true
  validates :game, presence: true
  validates :game_type, presence: true
  validates :details, presence: true

  validate do |tournament|
    if tournament.new_record? && tournament.starts_at.present?
      if tournament.starts_at < (Time.now + 7.days)
        tournament.errors.add :starts_at, "must be at least a week away."
      end
    end
  end

  validate do |tournament|
    unless tournament.player_limit.pow2?
      tournament.errors.add :player_limit, "must be a power of 2."
    end
  end

  validate do |tournament|
    if tournament.stream_slug.present?
      unless Stream.where(slug: tournament.stream_slug).exists?
        tournament.errors.add :stream_slug, "must point to a valid stream."
      end
    end
  end

  def signup_open?
    starts_at >= DateTime.now
  end

  def started?
    !signup_open?
  end

  def full?
    players.checked_in.count >= player_limit
  end

  def ended?
    checked_in_players  = players.checked_in.count
    finished_players    = players.checked_in.where(current_position: nil).count

    checked_in_players >= 2 && checked_in_players == finished_players
  end

  def checkin_date
    starts_at - checkin_hours.hours
  end

  def checkin_open?
    now = DateTime.now
    now > checkin_date && now < starts_at
  end

  def checkin_open_for?(user)
    checkin_open? && signed_up?(user)
  end

  def checked_in?(user)
    players.checked_in.where(user: user).exists?
  end

  def signed_up?(user)
    players.where(user: user).exists?
  end

  def to_s
    name
  end

  def to_param
    slug
  end

  def move_to_next_state!
    prizepool_submitted! if prizepool.present? && prizepool_required?
  end

  # This is just a convenience method for development/console use.
  def report_scores_for!(username, mine, his)
    players.find_by(username: username).report_scores!(mine, his)
  end

  def player_for_user(user)
    query = user.is_a?(String) ? {username: user} : {user_id: user.id}
    players.find_by(query)
  end

  def generate_brackets!
    self.brackets = { "teams" => [], "results" => [] }

    # Split up players and seeds
    seeds = self.players.checked_in.to_a.clone
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

    # Go through and set up the first round for the winners, losers, finals.
    self.brackets["results"] = [
      [Array.new(self.brackets["teams"].count)      { [] }],  # winners
      [Array.new(self.brackets["teams"].count / 2)  { [] }],  # losers
      [[[], []]]                                              # finals
    ]

    # Set up all subsequent rounds as well, to avoid nil errors.
    Math.log2(self.brackets["teams"].count).to_i.times do
      self.brackets["results"][0] << []
    end

    # Subtracting 1 because we've already set up the first round.
    (number_of_losers_bracket_rounds - 1).times do
      self.brackets["results"][1] << []
    end

    # Always 2 rounds in the finals.
    self.brackets["results"][2] = [[], []]

    # Throw an exception if anything goes wrong here.
    save!

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

    players.each(&:set_current_position!)
  end

  def number_of_winners_bracket_rounds
    Math.log2(self.brackets["teams"].flatten.count).to_i
  end

  def number_of_losers_bracket_rounds
    2 * (Math.log2(self.brackets["teams"].flatten.count).to_i - 1)
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
    ["DateTime", "Date", "Time"].include?(string.class.name) ? string : Chronic.parse(string, time_class: Time.zone)
  end

  def starts_at=(value)
    write_attribute(:starts_at, parse_datetime(value))
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
    self.prizepool_total = prizepool.values.map { |val| BigDecimal.new(val.gsub(/[^\d\.]+/, "")) }.reduce(:+) || BigDecimal.new("0")
  end

  def set_tournament_slug
    # We want to remove all non-word charcters, reduce multiple consecutive
    # spaces down to a single space, and replace the spaces with dashes.
    self.slug = self.name.to_s.downcase.gsub(/[^\w\s]+/i, "").gsub(/\s+/, "-")
  end
end
