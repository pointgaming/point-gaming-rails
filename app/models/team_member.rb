class TeamMember
  include Mongoid::Document
  include Mongoid::Timestamps

  after_create :increment_team_member_count
  after_destroy :decrement_team_member_count

  field :_id, :type => String, :default => proc{ "#{self.team_id}-#{self.user_id}" }
  field :rank, :type => String, :default => ''

  belongs_to :team
  belongs_to :user

  validates :rank, :presence=>true

  def leader?
    rank === 'Leader'
  end

  def rank_options
    ['Recruit', 'Member', 'Officer', 'Leader']
  end

private

  def increment_team_member_count
    self.team.inc :member_count, 1
  end

  def decrement_team_member_count
    self.team.inc :member_count, -1
  end
end
