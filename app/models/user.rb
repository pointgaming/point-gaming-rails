class User
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Paperclip
  include Tire::Model::Search
  include Tire::Model::CustomCallbacks
  include Services::Resque
  require 'obscenity/active_model'
  include PointGamingRailsUrlHelper

  has_mongoid_attached_file :avatar, :default_url => "/assets/logo.png", styles: {thumb: '50x50', medium: '200'}

  before_validation :populate_slug

  before_create :create_forum_user
  before_create :create_store_user
  before_update :update_forum_user
  before_update :update_store_user
  after_destroy :destroy_forum_user
  after_destroy :destroy_store_user
  after_save :enqueue_team_points_recalculation
  after_save :enqueue_reputation_recalculation

  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :multi_token_authenticatable, :recoverable,
         :rememberable, :trackable, :validatable

  attr_accessor :registration_pin

  field :_id, :type => String, :default => proc{ UUIDTools::UUID.random_create.to_s }

  ## Database authenticatable
  field :email,              :type => String, :default => ""
  field :encrypted_password, :type => String, :default => ""

  ## Recoverable
  field :reset_password_token,   :type => String
  field :reset_password_sent_at, :type => Time

  ## Rememberable
  field :remember_created_at, :type => Time

  ## Trackable
  field :sign_in_count,      :type => Integer, :default => 0
  field :current_sign_in_at, :type => Time
  field :last_sign_in_at,    :type => Time
  field :current_sign_in_ip, :type => String
  field :last_sign_in_ip,    :type => String

  field :is_muted, :type => Boolean #is not saved into the DB, is used only to get the info about member for game room, is initialized localy to respond

  ## Confirmable
  # field :confirmation_token,   :type => String
  # field :confirmed_at,         :type => Time
  # field :confirmation_sent_at, :type => Time
  # field :unconfirmed_email,    :type => String # Only if using reconfirmable

  ## Lockable
  # field :failed_attempts, :type => Integer, :default => 0 # Only if lock strategy is :failed_attempts
  # field :unlock_token,    :type => String # Only if unlock strategy is :email or :both
  # field :locked_at,       :type => Time

  ## Token authenticatable
  # field :authentication_token, :type => String

  field :username
  field :slug, :type => String, :default => ''
  field :first_name
  field :last_name
  field :time_zone, default: Rails.application.config.time_zone
  field :birth_date, type: Date
  field :phone
  field :country, default: ''
  field :state
  field :points, type: Integer, default: 0
  field :cash, type: BigDecimal, default: BigDecimal.new("0")
  field :friend_count, :type => Integer, :default => 0
  field :stream_owner_count, :type => Integer, :default => 0
  field :reputation, :type => BigDecimal, :default => BigDecimal.new("100")
  field :match_participation_count, type: Integer, default: 0
  field :dispute_won_count, :type => Integer, :default => 0
  field :dispute_lost_count, :type => Integer, :default => 0
  field :stripe_customer_token
  field :take_over_time, :type => DateTime, default: Time.now - 24.hours

  # online/offline chat status
  field :status, default: 'offline'

  attr_accessible :username, :first_name, :last_name, :email, :password, :password_confirmation,
                  :remember_me, :status, :birth_date, :age, :phone, :profile_attributes,
                  :avatar, :country, :state, :game, :time_zone, :registration_pin

  validates_presence_of :username, :slug, :first_name, :last_name
  validates_uniqueness_of :username, :slug, :email, :case_sensitive => false

  validates :username, :format => {:with => APP_CONFIG[:display_name_regex], message: APP_CONFIG[:display_name_regex_message]}, obscenity: true
  validates :registration_pin, presence: true, on: :create
  validate :confirm_registration_pin, on: :create

  def confirm_registration_pin
    correct_pin = SiteSetting.where(key: :registration_pin).first.try(:value) || 'pgrpin'
    self.errors[:base] << "Invalid Registration pin" unless registration_pin === correct_pin
  end

  belongs_to :profile
  belongs_to :game
  belongs_to :team
  belongs_to :group

  has_many :auth_tokens, :validate=>false
  has_many :coins, :validate=>false
  has_many :friends, :validate=>false
  has_many :blocked_users, :validate=>false
  has_many :configs, class_name: 'UserConfig'
  has_many :subscriptions
  has_many :orders
  has_many :disputes, inverse_of: :owner
  has_many :demos
  has_many :sponsors, class_name: 'UserSponsor'
  has_many :team_members
  has_many :transaction_history, class_name: 'UserTransactionHistory'
  has_many :billing_history, class_name: 'UserBillingHistory'
  has_many :cash_history, class_name: 'UserCashHistory'
  has_many :point_history, class_name: 'UserPointHistory'
  has_many :lobbies, class_name: 'UserLobby'

  accepts_nested_attributes_for :profile

  def ability
    @ability ||= Ability.new(self)
  end
  delegate :can?, :cannot?, :to => :ability

  def admin?
    group.present?
  end
  alias_method :admin, :admin?

  def birth_date=(value)
    write_attribute(:birth_date, Date.strptime(value, '%m/%d/%Y')) if value.present?
  end

  def bets
    Bet.for_user(self).all
  end

  def teams
    team_members.map(&:team)
  end

  def increment_points!(amount)
    raise TypeError, "Amount must be a Fixnum." unless amount.class.name === 'Fixnum'

    begin
      inc(:points, amount)
    rescue => e
      Rails.logger.error "User#increment_points! failed to increment user #{self._id} points by #{amount}."
      raise e
    end
  end

  def increment_dispute_lost_count!(amount=1)
    inc :dispute_lost_count, amount

    Resque.enqueue RecalculateUserReputationJob, _id
  end

  def increment_dispute_won_count!(amount=1)
    inc :dispute_won_count, amount
  end

  def age
    return "" unless birth_date?

    today = Date.today
    age = today.year - birth_date.year
    age -= 1 if birth_date.yday > Date.today.yday
    age
  end

  def to_param
    self.slug
  end

  def profile_url
    user_url(self)
  end

  def as_json(options={})
    json = super({
      methods: [:profile_url, :age, :slug]
    }.merge(options))

    json[:avatar] = avatar.url
    json
  end

  def display_name
    username
  end

  def has_active_subscription?
    subscriptions.active.first.present?
  end

  def has_stripe_token?
    self.stripe_customer_token.present?
  end

  def stream_limit
    50
  end

  def update_reputation
    self.reputation = if dispute_lost_count === 0
      BigDecimal.new("100")
    elsif match_participation_count === 0
      BigDecimal.new("0")
    else
      BigDecimal.new("100") - (BigDecimal.new("100") *
        (BigDecimal.new(dispute_lost_count) / BigDecimal.new(match_participation_count)) )
    end
  end

  def update_match_participation_count
    self.match_participation_count = self.bets.group_by(&:match_id).length
  end

  def blocked_user?(user)
    BlockedUser.where(user_id: self._id, blocked_user_id: user._id).exists?
  end

  def friend_request_sent?(user)
    FriendRequest.where(user_id: id, friend_request_user_id: user.id).exists?
  end

  def friends_with?(user)
    Friend.where(user_id: id, friend_user_id: user.id).exists? &&
      Friend.where(user_id: user.id, friend_user_id: id).exists?
  end

  def team_member?(team)
    team_members.for_team(team).exists?
  end

  def store_sort
    90
  end

  def main_sort
    0
  end

  def forum_sort
    90
  end

  def to_s
    username
  end

  def self.find_first_by_auth_conditions(warden_conditions)
    conditions = warden_conditions.dup
    if username = conditions.delete(:username)
      self.any_of({ :username =>  /^#{Regexp.escape(username)}$/i }, { :email =>  /^#{Regexp.escape(username)}$/i }).first
    else
      super
    end
  end

  def can_take_over?(game_room)
    return (!game_room.owner.eql?(self) && self.points >= 2 * game_room.owner.points && self.take_over_time + 24.hours < Time.now)
  end

  def can_hold?(game_room)
    return game_room.owner.eql?(self) && self.team.present? && team_member?(self.team) && self.as_team_member.can_edit_team?
  end

  def as_team_member
    return self.team_members.where(team: self.team).first
  end

  def is_banned_for? game
    user_ban = UserBan.where(user: self, game: game).first
    user_ban.delete if user_ban.present? && user_ban.is_expired?
    return UserBan.where(user: self, game: game).first.present?
  end

  def team
    if self.team_id.present?
      team = Team.where(id: self.team_id).first
      team.temporarily = false
    else
      user_team = UserTeam.where(user: self).first
      if user_team.present?
        team = user_team.team
        team.temporarily = true
      end
    end
    return team
  end

  def team_for game_room
    user_team = UserTeam.where(user: self, game_room: game_room).first
    team = self.team
    if user_team && !user_team.expired?
      team = user_team.team
      team.temporarily = true
    end
    return team
  end

  def mute_in game_room
    UserMute.create(user: self, game_room: game_room)
  end

  def is_muted_in? game_room
    UserMute.where(user: self, game_room: game_room).first.present?
  end

  settings analysis: {
      analyzer: {
        partial_match: {
          tokenizer: :whitespace,
          filter: [:lowercase, :ngram]
        }
      },
      filter: {
        ngram: {
            max_gram: 20,
            min_gram: 1,
            type: :nGram
        }
      }
    } do
    mapping do
      indexes :display_name, type: 'string', boost: 10, analyzer: 'snowball', as: 'username'
      indexes :prefix, type: 'string', index_analyzer: 'partial_match', search_analyzer: 'snowball', boost: 2, as: 'username'
      indexes :url, type: 'string', :index => 'no', as: 'profile_url'

      indexes :store_sort, type: 'short', :index => 'not_analyzed', as: 'store_sort'
      indexes :main_sort, type: 'short', :index => 'not_analyzed', as: 'main_sort'
      indexes :forum_sort, type: 'short', :index => 'not_analyzed', as: 'forum_sort'
    end
  end

protected

  def populate_slug
    self.slug = username.downcase.gsub(/\s/, "_") if username.present?
    true
  end

  def create_forum_user
    forum_user = ForumUser.new :email => self.email, :username => self.username, avatar_thumb_url: self.avatar.url(:thumb)
    if forum_user.save
      true
    else
      self.errors[:base] << "Failed to create your forum account."
      false
    end
  rescue Errno::ECONNREFUSED
    Rails.logger.warn 'Failed to create forum account: Errno::ECONNREFUSED'
  end

  def update_forum_user
    if self.email_changed? || self.username_changed? || self.avatar_updated_at_changed?
      forum_user = ForumUser.find self.email_was
      forum_user.email = self.email
      forum_user.username = self.username
      forum_user.avatar_thumb_url = self.avatar.url(:thumb)
      if forum_user.save
        true
      else
        self.errors[:base] << "Failed to update your forum account."
        false
      end
    end
  end

  def destroy_forum_user
    begin
      forum_user = ForumUser.find self.email
      forum_user.destroy
    rescue ActiveResource::ResourceNotFound
      # forumUser was not found
    end
  end

  def create_store_user
    store_user = Store::User.new :email => self.email, :username => self.username
    if store_user.save
      true
    else
      self.errors[:base] << "Failed to create your store account."
      false
    end
  rescue Errno::ECONNREFUSED
    Rails.logger.warn 'Failed to create store account: Errno::ECONNREFUSED'
  end

  def update_store_user
    if self.email_changed? || self.username_changed?
      store_user = Store::User.find self.email_was
      store_user.email = self.email
      store_user.username = self.username
      if store_user.save
        true
      else
        self.errors[:base] << "Failed to update your store account."
        false
      end
    end
  end

  def destroy_store_user
    begin
      store_user = Store::User.find self.email
      store_user.destroy
    rescue ActiveResource::ResourceNotFound
      # StoreUser was not found
    end
  end

  def enqueue_reputation_recalculation
    return unless resque_available?
    if match_participation_count_changed? || dispute_lost_count_changed?
      Resque.enqueue RecalculateUserReputationJob, _id
    end
  end

  def enqueue_team_points_recalculation
    return unless resque_available?
    if team_id_changed?
      Resque.enqueue RecalculateTeamPointsJob, team_id_was if team_id_was.present?
      Resque.enqueue RecalculateTeamPointsJob, team_id if team_id.present?
    elsif team_id.present? && game_id_changed?
      Resque.enqueue RecalculateTeamPointsJob, team_id
    end
  end
end
