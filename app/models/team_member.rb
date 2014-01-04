class TeamMember
  include Mongoid::Document
  include Mongoid::Timestamps

  scope :for_team, lambda {|team| where(team_id: team._id)}

  after_create :set_as_active_team, if: :first_team?
  after_create :increment_team_member_count
  after_destroy :decrement_team_member_count

  field :_id, :type => String, :default => proc{ "#{self.team_id}-#{self.user_id}" }
  field :rank, :type => String, :default => ''

  belongs_to :team
  belongs_to :user

  validates :rank, :presence=>true
  validate :validate_leader_limit

  def is_leader?
    rank === 'Leader'
  end

  def is_manager?
    rank === 'Manager'
  end

  def can_edit_team?
    is_leader? || is_manager?
  end

  def first_team?
    user.teams.count == 1
  end

  def rank_options
    ['Member', 'Manager', 'Leader']
  end

private

  def set_as_active_team
    user.team = team
    user.save
  end

  def validate_leader_limit
    if is_leader? && team.members.nin(_id: _id).where(rank: 'Leader').exists?
      self.errors[:base] << "There can only be one team leader at a time"
    end
  end

  def increment_team_member_count
    self.team.inc :member_count, 1
  end

  def decrement_team_member_count
    self.team.inc :member_count, -1
  end
end
