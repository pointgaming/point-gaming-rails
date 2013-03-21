class GameRoom
  include Mongoid::Document

  scope :for, lambda {|game| where(game_id: game._id) }

  after_create :publish_created
  after_update :publish_updated
  after_destroy :publish_destroyed

  field :position, type: Integer
  field :is_advertising, type: Boolean, default: false
  field :is_locked, type: Boolean, default: false
  field :member_count, type: Integer, default: 0
  field :max_member_count, type: Integer, default: 99
  field :description, :type => String, :default => ''

  belongs_to :game
  belongs_to :owner, class_name: 'User'

  # has_and_belongs_to_many :team_bots

  validates :position, presence: true, uniqueness: true, numericality: {only_integer: true, greater_than: 0, less_than: 1000}
  validates :max_member_count, :presence=>true

  def mq_exchange
    "GameRoom_#{_id}"
  end

private

  def publish_created
    BunnyClient.instance.publish_fanout("c.#{self.game.mq_exchange}", {
      :action => 'GameRoom.new',
      :data => {
        :game_room => self.as_json(:include => [:owner])
      }
    }.to_json)
  end

  def publish_updated
    BunnyClient.instance.publish_fanout("c.#{self.game.mq_exchange}", {
      :action => 'GameRoom.update',
      :data => {
        :game_room => self.as_json(:include => [:owner])
      }
    }.to_json)
  end

  def publish_destroyed()
    BunnyClient.instance.publish_fanout("c.#{self.game.mq_exchange}", {
      :action => 'GameRoom.destroy', 
      :data => {
        :game_room => self.as_json(:include => [:owner])
      }
    }.to_json)
  end
end