class Tournament
  include Mongoid::Document

  cattr_reader :formats, :types

  before_validation :set_tournament_slug, on: :create
  before_save :set_stream_slug

  @@formats = [:single_elimination, :double_elimination]
  @@types = [:open, :invite]

  scope :pending, lambda { where(:activated.ne => true) }
  scope :activated, lambda { where(activated: true) }
  scope :collaborated, lambda { |user| any_of({ owner_id: user.id }, { admins: user.id }) }

  field :name
  field :slug
  field :stream_name
  field :stream_slug
  field :starts_at, type: DateTime
  field :checkin_hours, type: Integer, default: 1
  field :player_limit, type: Integer, default: MAX_PLAYERS
  field :format
  field :type
  field :payment
  field :details, default: I18n.t("tournament.form.details")
  field :prizepool, type: Hash, default: {}
  field :prizepool_total, type: BigDecimal, default: BigDecimal.new("0")
  field :sponsor_request_state, default: "not_requested"
  field :admins, type: Array, default: []
  field :invites, type: Array, default: []
  field :has_groupstage, type: Boolean
  field :invite_only, type: Boolean
  field :activated, type: Boolean, default: false

  # The brackets format here needs to match the format used in the jQuery
  # brackets library. Here's an example:
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

  belongs_to :game
  belongs_to :game_type
  belongs_to :sponsor_request
  belongs_to :owner, class_name: "User"

  has_many :sponsors, dependent: :destroy
  embeds_many :players

  validates :name, presence: true, uniqueness: true
  validates :slug, presence: true, uniqueness: true
  validates :starts_at, presence: true
  validates :checkin_hours, presence: true, numericality: { only_integer: true, greater_than: 0, less_than: 4 }
  validates :player_limit, presence: true, numericality: { only_integer: true, greater_than: 0, less_than: MAX_PLAYERS + 1, even: true }
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
    if tournament.stream_name.present?
      unless Stream.where(name: tournament.stream_name).exists?
        tournament.errors.add :stream_name, "must point to a valid stream."
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
    now > checkin_date && now < starts_at && players.checked_in.count < player_limit
  end

  def checkin_open_for?(user)
    checkin_open? && signed_up?(user)
  end

  def checked_in?(user)
    players.for_user(user).checked_in.exists?
  end

  def signed_up?(user)
    players.for_user(user).exists?
  end

  def check_in!(player)
    player.update_attributes(checked_in_at: DateTime.now)
    generate_brackets!
  end

  def kick!(player)
    player.destroy
    generate_brackets!
  end

  def to_s
    name
  end

  def to_param
    slug
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

    save and return unless self.players.checked_in.count >= 2

    # Add BYEs if we have n players where n is not a power of 2
    self.players.unscoped.where(username: "BYE").destroy
    while self.players.unscoped.checked_in.count & (self.players.unscoped.checked_in.count - 1) != 0
      self.players.create(username: "BYE", seed: 9999, checked_in_at: Time.now)
    end

    # Perform the seeding.
    bracket_list = self.players.unscoped.checked_in.to_a.clone
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
      self.brackets["teams"] << [pair[0].id, pair[1].id]
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

    players.unscoped.checked_in.each(&:set_current_position!)

    # If there are any BYEs, have the other player automatically report a win.
    3.times do
      players.unscoped.bye.where(:current_position.ne => nil).each do |bye|
        opponent = bye.current_opponent
        opponent.report_scores!(1, 0) if opponent != "TBD"
      end
    end

    true
  end

  def number_of_winners_bracket_rounds
    Math.log2(self.brackets["teams"].flatten.count).to_i
  end

  def number_of_losers_bracket_rounds
    2 * (Math.log2(self.brackets["teams"].flatten.count).to_i - 1)
  end

  def prizepool_submitted
    if !prizepool.present? || prizepool.values.all? { |item| !item.present? }
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

  def update_prizepool_total
    self.prizepool_total = prizepool.values.map { |val| BigDecimal.new(val.gsub(/[^\d\.]+/, "")) }.reduce(:+) || BigDecimal.new("0")
  end

  def set_tournament_slug
    # We want to remove all non-word charcters, reduce multiple consecutive
    # spaces down to a single space, and replace the spaces with dashes.
    self.slug = self.name.to_s.downcase.gsub(/[^\w\s]+/i, "").gsub(/\s+/, "-") if name_changed?
  end

  def set_stream_slug
    self.stream_slug = Stream.where(name: stream_name).first.try(:slug) if stream_name_changed?
  end
end
