class GameRoom
  include Mongoid::Document

  # game room positions shouldn't shift after this limit
  POSITION_MAX_SHIFT_THRESHOLD = 10

  scope :for, lambda {|game| where(game_id: game._id) }

  after_create :publish_created
  after_update :publish_updated
  after_destroy :publish_destroyed
  after_destroy :cancel_match

  attr_accessor :takeover_position

  field :betting, :type => Boolean, :default => true
  field :position, type: Integer
  field :is_advertising, type: Boolean, default: false
  field :is_locked, type: Boolean, default: false
  field :member_count, type: Integer, default: 0
  field :max_member_count, type: Integer, default: 99
  field :description, :type => String, :default => ''

  belongs_to :game
  belongs_to :owner, class_name: 'User'
  belongs_to :match

  has_many :matches, as: :room

  # has_and_belongs_to_many :team_bots

  validates :position, presence: true, numericality: {only_integer: true, greater_than: 0, less_than: 1000}
  validates :max_member_count, :presence=>true

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
    BunnyClient.instance.publish_fanout("c.#{self.game.mq_exchange}", ::RablRails.render(self, 'api/v1/game_rooms/socket_new'))
  end

  def publish_updated
    BunnyClient.instance.publish_fanout("c.#{self.game.mq_exchange}", ::RablRails.render(self, 'api/v1/game_rooms/socket_update'))
  end

  def publish_destroyed()
    BunnyClient.instance.publish_fanout("c.#{self.game.mq_exchange}", ::RablRails.render(self, 'api/v1/game_rooms/socket_destroy'))
  end

  def cancel_match
    self.match.cancel! if self.match.present?
  end

end
