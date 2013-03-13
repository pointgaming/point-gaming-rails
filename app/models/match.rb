class Match
  include Mongoid::Document
  include Mongoid::Timestamps
  include Workflow

  field :betting, :type => Boolean, :default => true
  field :map, :type => String, :default => ''
  field :state, :type => String

  workflow_column :state
  workflow do
    state :new do
      event :start, transition_to: :started
      event :cancel, transitions_to: :cancelled
    end 
    state :started do
      event :stop, transitions_to: :stopped
    end 
    state :stopped do
      event :finalize, transitions_to: :finalized
    end 
    state :cancelled
    state :finalized
  end

  belongs_to :room, :polymorphic => true
  belongs_to :player_1, :polymorphic => true
  belongs_to :player_2, :polymorphic => true
  belongs_to :winner, :polymorphic => true

  has_many :bets

  validates :player_1, :presence=>true
  validates :player_2, :presence=>true
  validates :map, :presence=>true

  attr_writer :player_1_name, :player_2_name
  
  def player_1_name
    player_1 ? player_1.playable_name : read_attribute("player_1_name")
  end

  def player_2_name
    player_2 ? player_2.playable_name : read_attribute("player_2_name")
  end

  def player_options
    [[player_1.playable_name, :player_1], [player_2.playable_name, :player_2]]
  end

  def start
    update_attribute(:betting, false)
  end

  def stop
    update_attribute(:betting, false)
  end

  def cancel
    update_attribute(:betting, false)
    self.room.match = nil;
    self.room.save
  end

  def finalize
    update_attribute(:betting, false)
    self.room.match = nil;
    self.room.save
  end
end
