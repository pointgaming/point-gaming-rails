class TeamBot
  include Mongoid::Document
  include Mongoid::Timestamps
  include Rails.application.routes.url_helpers

  after_create :mark_team_bot_field
  after_destroy :unmark_team_bot_field

  belongs_to :team
  belongs_to :game_room

  validates :team, :game_room, presence: true

  def mark_team_bot_field
    self.game_room.update_attributes(is_team_bot_placed: true)
  end

  def unmark_team_bot_field
    self.game_room.update_attributes(is_team_bot_placed: false)
  end
end
