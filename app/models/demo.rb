class Demo
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Paperclip

  field :winner_name, type: String
  field :loser_name, type: String
  field :map, type: String
  field :download_count, type: Integer, default: 0

  belongs_to :user, inverse_of: :demos
  belongs_to :game
  belongs_to :game_type
  belongs_to :winner, polymorphic: true
  belongs_to :loser, polymorphic: true

  has_mongoid_attached_file :attachment

  validates_attachment :attachment, presence: true, size: { :in => 0..20.megabytes }
  validates :loser_name, presence: true
  validates :winner_name, presence: true
  validates :map, presence: true
  validates :user, presence: true
  validates :game_type, presence: true
  validates :game, presence: true

  def participants
    "#{winner_name} vs #{loser_name}"
  end

end
