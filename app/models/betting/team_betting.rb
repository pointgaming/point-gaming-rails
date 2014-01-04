require 'active_support/concern'

module Betting
  module TeamBetting
    extend ActiveSupport::Concern

    included do
      embeds_many :betters, class_name: 'Betting::Better'
    end

    def offerer_team_members
      self.betters.select{|b| b.team_id == match.player_1_id}
    end

    def taker_team_members
      self.betters.select{|b| b.team_id == match.player_2_id}
    end    

    def team_size
      (match ? match.team_size : nil) || 0
    end

    def has_better_accepted?(user)
      self.betters.map(&:_id).include?(user.id)
    end

    def team_full?(team)
      self.betters.select{|b| b.team_id == team.id}.size >= team_size
    end

    def is_team_vs_mode?
      match && match.is_team_vs_mode? ? true : false
    end

    def teams_full?
      offerer_team_members.size == team_size &&
      taker_team_members.size == team_size
    end

    protected

      def accept_team_bet(user)
        if has_better_accepted?(user)
          errors.add(:betters, "user already accepted bet.") 
        elsif team_full?(user.team)
          errors.add(:betters, "team already has max players for this bet.") 
        elsif !can_team_join?(user.team)
          errors.add(:betters, "your team is not one of betting teams.") 
        else
          self.match.player_2 = user.team
          self.betters << Betting::Better.new(user: user, team: user.team)
          self.taker_choice = match.player_2 if user.team_id == match.player_2_id
          self.outcome = 'accepted' if teams_full?
        end
      end

      def can_team_join?(team)
        match.player_2_id.nil? || 
        match.player_1_id == team.id ||
        match.player_2_id == team.id
      end

      def check_offering_team_points
        pending_points = pending_team_points(offering_team)

        if offerer_wager > (offering_team.points - pending_points)
          errors.add(:offerer_wager, "cannot be larger than your available team points.") 
        end
      end

      def check_taking_team_points
        pending_points = pending_team_points(taking_team)

        if taker_wager > (taking_team.points - pending_points)
          errors.add(:taker_wager, "cannot be larger than your available team points.") 
        end
      end

    private

      def pending_team_points(team)
        pending_matches = Match.where(:$or => [{state: 'new'},{state: 'started'}])
        match_ids = pending_matches.where(player_1_id: team.id)
        match_ids = match_ids.map(&:id).select{|id| id != match_id }
        points = Bet.where(match_id: {:$in => match_ids}).sum(:offerer_wager).to_i
        match_ids = pending_matches.where(player_2_id: team.id).map(&:id).select{|id| id != match_id }
        points += Bet.where(match_id: {:$in => match_ids}).sum(:taker_wager).to_i
        points
      end

      def offering_team
        match.player_1
      end

      def taking_team
        match.player_2
      end      
  end
end