class GameRoom
  include Mongoid::Document
  include Services::Resque

  # game room positions shouldn't shift after this limit
  POSITION_MAX_SHIFT_THRESHOLD = 10

  BET_TYPES = %w(team 1v1)

  scope :for, lambda {|game| where(game_id: game && game._id) }

  after_create :publish_created
  after_create :ensure_game_room_has_members
  after_update :destroy_if_no_members
  after_update :publish_updated
  after_destroy :publish_destroyed
  after_destroy :cancel_match

  attr_accessor :takeover_position

  field :betting, :type => Boolean, :default => true
  field :betting_type, :type => String, :default => '1v1'
  field :position, type: Integer
  field :is_advertising, type: Boolean, default: false
  field :is_locked, type: Boolean, default: false
  field :member_count, type: Integer, default: 0
  field :max_member_count, type: Integer, default: 99
  field :description, :type => String, :default => ''
  field :is_team_bot_placed, type: Boolean, default: false

  belongs_to :game
  belongs_to :owner, class_name: 'User'
  belongs_to :match

  has_many :matches, as: :room
  has_and_belongs_to_many :members, class_name: 'User'

  # has_and_belongs_to_many :team_bots
  has_one :team_bot, dependent: :destroy

  validates :position, presence: true, numericality: {only_integer: true, greater_than: 0, less_than: 1000}
  validates :max_member_count, :presence=>true
  validates :game, presence: true
  validates :betting_type, :inclusion => { :in => BET_TYPES }

  validate :check_position_uniqueness
  validate :check_game_room_owner_count

  def mq_exchange
    "GameRoom_#{_id}"
  end

  def self.next_available_position(game)
    position = POSITION_MAX_SHIFT_THRESHOLD + 1
    until !GameRoom.for(game).where(position: position).exists? do
      position += 1
    end
    position
  end

  def move_to_next_position!
    if position < POSITION_MAX_SHIFT_THRESHOLD
      self.position += 1
      next_room = GameRoom.for(game).where(position: position).nin(_id: _id).first
      next_room.move_to_next_position! if next_room.present?
      save
    else
      # move room to next available position
      self.position = GameRoom.next_available_position(game)
      save
    end
  end

  def add_user_to_members!(user)
    if _id != user._id && !members.include?(user)
      self.members << user
      update_member_count!
    end
  end

  def remove_user_from_members!(user)
    self.members.delete(user)
    update_member_count!
  end

  def update_member_count!
    self.member_count = members.length
    save
  end

  def is_1v1?
    betting_type == '1v1'
  end

  def pending_matches
    matches.where(state: 'new').all.to_a
  end

  def bets
    b = matches.where(state: 'new')
    b = b.includes(:bets)
    b = b.map(&:bets)
    b.flatten
  end

  def take_over user
    new_game_room = GameRoom.new game: self.game, position: self.position, owner: user
    self.shift_in_rate_queue
    new_game_room.save
    #user.update_attributes take_over_time: Time.now does not work, need to change the code below
    user.take_over_time = Time.now
    user.save
  end

  def shift_in_rate_queue
    self.update_attributes(position: GameRoom.next_available_position(self.game)) and return if self.position >= POSITION_MAX_SHIFT_THRESHOLD
    next_position_game = GameRoom.where(position: self.position + 1).first
    next_position_game.shift_in_rate_queue if next_position_game
    self.update_attributes(position: self.position + 1)
  end

  def hold user
    team_bot = TeamBot.create(game_room: self, team: user.team)
  end

  def is_free?
    self.team_bot.blank?
  end

private

  # FIXME: this needs to be implemented properly (check team/team bot points)
  # returns true if the same users owns both game rooms
  def can_takeover_room?(room_to_takeover)
    owner_id === room_to_takeover.owner_id || owner.points > room_to_takeover.owner.points
  end

  def attempt_to_takeover_room(room_to_takeover)
    unless can_takeover_room?(room_to_takeover)
      self.errors[:base] << "Unable to takeover position."
      return false
    end

    room_to_takeover.move_to_next_position!
    true
  end

  # this method may call itself (recursive)
  def check_position_uniqueness(takeover_attempted=false)
    existing_room = GameRoom.for(game).where(position: self.position).nin(_id: self._id).first
    return unless existing_room.present?
    if takeover_position && takeover_attempted != true
      self.takeover_position = false
      check_position_uniqueness(true) if attempt_to_takeover_room(existing_room)
    else
      self.errors[:base] << (takeover_attempted ? "Failed to takeover position." : "Position has already been taken")
    end
  end

  def check_game_room_owner_count
    if GameRoom.where(game_id: self.game_id, owner_id: self.owner_id).nin(_id: self._id).exists?
      self.errors[:base] << "User already owns a Game Room in this lobby"
    end
  end

  def publish_created
    BunnyWrapper.publish_fanout("c.#{self.game.mq_exchange}", 
                                ::RablRails.render(self, 'game_rooms/socket_new')) if rabl_available?
  end

  def publish_updated
    BunnyWrapper.publish_fanout("c.#{self.game.mq_exchange}", 
                                ::RablRails.render(self, 'game_rooms/socket_update')) if rabl_available?
  end

  def publish_destroyed
    BunnyWrapper.publish_fanout("c.#{self.game.mq_exchange}", 
                                ::RablRails.render(self, 'game_rooms/socket_destroy')) if rabl_available?
  end

  def ensure_game_room_has_members
    Resque.enqueue_in(1.minute, DestroyGameRoomIfNoMembersJob, _id) if resque_available?
  end

  def destroy_if_no_members
    if member_count_changed? && member_count === 0 && member_count_was > 0
      destroy
    end
  end

  def cancel_match
    self.match.cancel! if self.match.present?
  end

  def rabl_available?
    defined? ::RablRails
  end
end
