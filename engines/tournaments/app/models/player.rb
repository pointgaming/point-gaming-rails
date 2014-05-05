class Player
  include Mongoid::Document

  default_scope asc(:seed)

  before_validation :set_username!

  scope :for_user, lambda { |user| where(user_id: user._id) }
  scope :checked_in, where(:checked_in_at.ne => nil)

  field :checked_in_at, type: DateTime
  field :username, type: String
  field :seed, type: Integer
  field :placed, type: Integer
  field :current_position, type: Array

  embedded_in :tournament
  belongs_to :user

  validates_presence_of :user_id, :username

  def checked_in?
    checked_in_at.is_a?(DateTime)
  end

  def report_scores!(mine, his)
    # Only the winner can report scores. Scores cannot be equal.
    return false if mine <= his
    return false if current_opponent == "TBD"

    results = tournament.brackets["results"]
    index   = starting_index()

    # If we return at this point, there's a serious problem.
    return if index.nil?

    index_data = follow_bracket(0, 0, index, starting_team)

    if index_data.is_a?(Array)
      # The score needs to be in the correct order for the brackets.
      b = index_data[0]
      r = index_data[1]
      i = index_data[2]

      # Here, we set the score for the game based on the index we've received
      # from the follow_bracket call.
      score = index_data[3] == 0 ? [mine, his] : [his, mine]
      results[b][r][i] = score

      tournament.brackets["results"] = results
      tournament.save!

      opponent = current_opponent()
      opponent.set_current_position! unless opponent == "TBD"

      set_current_position!

      tournament.players.each(&:set_placed!) if tournament.ended?

      true
    else
      false
    end
  end

  def knocked_out?
    follow_bracket(0, 0, starting_index, starting_index) == -2
  end

  def current_opponent
    opponent_position = [
      current_position[0],
      current_position[1],
      current_position[2],
      current_position[3].zero?? 1 : 0
    ]

    tournament.players.find_by(current_position: opponent_position)
  rescue
    "TBD"
  end

  def set_current_position!
    index_data = follow_bracket(0, 0, starting_index, starting_team)
    set(:current_position, index_data.is_a?(Array) ? index_data : nil)
  end

  def set_placed!
    place = follow_bracket(0, 0, starting_index, starting_team)
    self.set(:placed, place.is_a?(Integer) ? place : nil)
  end

  def to_s
    username
  end

  private

  def starting_index
    tournament.brackets["teams"].each_with_index do |pair, i|
      return i if pair[0] == id || pair[1] == id
    end
  end

  def starting_team
    tournament.brackets["teams"][starting_index].index(id)
  end

  def follow_bracket(bracket, round, index, team)
    #puts "#{username}\t#{bracket} #{round} #{index} #{team}"
    # +bracket+ 0 -> winner
    # +bracket+ 1 -> loser
    # +bracket+ 2 -> final
    # +index+ describes the index in the round
    # +team+ is either a 0 or 1. See Tournament.brackets structure.

    results         = self.tournament.brackets["results"]
    opponent        = team == 0 ? 1 : 0
    result          = results[bracket][round][index]  rescue nil
    team_score      = result[team]                    rescue nil
    opponent_score  = result[opponent]                rescue nil

    if result.blank?
      # This is the position that we're reporting for.
      return [bracket, round, index, team]
    elsif bracket == 2
      # We've reached the finals bracket and the score is already reported.
      win = team_score > opponent_score

      # These numbers represent top 4 placings
      if index == 0
        return win ? 1 : 2
      elsif index == 1
        return win ? 3 : 4
      end
    else
      win = team_score > opponent_score

      # Let's check whether or not we're a finalist here, before getting into
      # winner/loser bracket placement.
      if bracket == 0 && round == (tournament.number_of_winners_bracket_rounds - 1)
        if win
          # Either going to be placed 1st or 2nd.
          return follow_bracket(2, 0, 0, 0)
        else
          # Dropping to loser's bracket. Still a chance to make 1st.
          return follow_bracket(1, tournament.number_of_losers_bracket_rounds - 1, 0, 1)
        end
      elsif bracket == 1 && round >= (tournament.number_of_losers_bracket_rounds - 2)
        if round == (tournament.number_of_losers_bracket_rounds - 1)
          if win
            return follow_bracket(2, 0, 0, 1)
          else
            return follow_bracket(2, 0, 1, 1)
          end
        elsif round == (tournament.number_of_losers_bracket_rounds - 2)
          # If you lose before the final losers bracket round, you can still make
          # 3rd place.
          if win
            return follow_bracket(1, tournament.number_of_losers_bracket_rounds - 1, 0, 0)
          else
            return follow_bracket(2, 0, 1, 0)
          end
        end
      end

      # All of the following logic is for traversing the bracket tree as a
      # non-finalist.
      if win
        if bracket == 0
          team  = index.even?? 0 : 1
          index = index / 2
        elsif bracket == 1
          if round.even?
            team  = 0
          else
            team  = index.even?? 0 : 1
            index = round.even?? index : index / 2
          end
        end

        # Stay in the same bracket, continue recursive traversal.
        return follow_bracket(bracket, round + 1, index, team)
      else
        if bracket == 0
          # We're dropping into the losers bracket. Figure out where we're
          # supposed to go. Most algorithms involve dropping down to the
          # "opposite" index in the odd-numbered rounds.
          #
          # The team is constant if you're dropping down to the losers bracket,
          # except for the first round.
          team = if round.zero?
                   index.even?? 0 : 1
                 else
                   1
                 end

          # Every losers bracket round has the same number of indices as its
          # corresponding winners bracket round, except the first round.
          index = if round.zero?
                    index / 2
                  elsif round.even?
                    index
                  else
                    count = tournament.brackets["teams"].flatten.count / (2 ** (round + 1))
                    count - (index + 1)
                  end

          # The losers bracket only takes in new players every other round,
          # so the round the player drops down to is (r * 2) - 1, except for
          # round 0.
          round = round.zero?? 0 : (round * 2) - 1

          return follow_bracket(1, round, index, team)
        elsif bracket == 1
          # If this is a loss and we're in the loser's bracket, we have
          # nowhere else to go. Return the placement here.
          #
          # Note that there cannot be a 6th place in tournaments, because there
          # can only be 2^n players. Therefore, 5th-8th place would be an
          # example of a tie.
          #
          # In a 16-player tournament, round 0/1 -> 9th
          #                            round 2/3 -> 5th

          round = round + 2 if round.even?
          round = round + 1 if round.odd?

          return (tournament.brackets["teams"].flatten.count / round) + 1
        end
      end
    end
  end

  def set_username!
    self.username = user.username if username.blank?
  end
end
