class Stream
  include Mongoid::Document

  field :name, :type => String, :default => ''
  field :details, :type => String, :default => ''
  field :team1, :type => String, :default => ''
  field :team2, :type => String, :default => ''
  field :map, :type => String, :default => ''
  field :betting, :type => Boolean, :default => true
  field :streaming, :type => Boolean, :default => false

  field :viewer_count, :type => Integer, :default => 0

  belongs_to :game

  has_many :bets
  has_many :collaborators, dependent: :destroy

  validates :name, :presence=>true
  validates :team1, :presence=>true, :if => :betting_enabled?
  validates :team2, :presence=>true, :if => :betting_enabled?
  validates :map, :presence=>true, :if => :betting_enabled?
  validates :betting, :presence=>true
  validates :viewer_count, :presence=>true

  def owner
    Collaborator.where(stream_id: self.id, owner: true).first
  end

  def bet_details
    betting ? "#{team1} vs #{team2} on #{map}" : ""
  end

  def team_options
    [[team1], [team2]]
  end

private

  def betting_enabled?
    betting
  end
end
