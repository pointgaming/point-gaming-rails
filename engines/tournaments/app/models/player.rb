class Player
  include Mongoid::Document

  after_create :increment_tournament_player_count
  after_destroy :decrement_tournament_player_count
  before_save :set_username

  # Update tournament brackets if there's a new player, 
  after_save :update_tournament_brackets, if: :checked_in_at_changed?
  after_destroy :update_tournament_brackets

  scope :for_user, lambda { |user| where(user_id: user._id) }

  field :checked_in_at, type: DateTime
  field :username, type: String
  field :seed, type: Integer
  field :current_position, type: Array

  embedded_in :tournament
  belongs_to :user

  def checked_in?
    checked_in_at.is_a?(DateTime)
  end

  def report_scores!(mine, his)
    # Only the winner can report scores. Scores cannot be equal.
    return if mine <= his

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

      # Now we need to figure out if our next opponent is ready. Specifically:
      # if the adjacent match is finished, we can set the match to be an empty
      # array, which is the way it gets marked as "pending". Matches in the
      # brackets that are nil reflect that we do not yet know who the opponents
      # are. Therefore, it's important that we only set a match as [] if we
      # know the opponent is ready.
      adjacent = i.even?? i + 1 : i - 1
      if results[b][r][adjacent].present?
        results[b][r + 1][i / 2] = []
      end

      tournament.brackets["results"] = results
      tournament.save

      opponent = current_opponent()

      opponent.set_current_position and opponent.save unless opponent == "TBD"
      set_current_position and save
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
      current_position[3] == 0 ? 1 : 0
    ]

    tournament.players.find_by(current_position: opponent_position)
  rescue
    "TBD"
  end

  def set_current_position
    index_data = follow_bracket(0, 0, starting_index, starting_team)
    self.current_position = index_data.is_a?(Array) ? index_data : nil
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
    # +bracket+ 0 -> winner
    # +bracket+ 1 -> loser
    # +bracket+ 2 -> final
    # +index+ describes the index in the bracket
    # +team+ is either a 0 or 1. See Tournament.brackets structure.
    #
    # results #=> [[ # WINNER BRACKET
    #   [[3,5], [2,4], [3,6], [2,3], [1,5], [5,3], [7,2], [1,2]],
    #   [[1,2], [3,4], [5,6], [7,8]],
    #   [[9,1], [8,2]],
    #   [[1,3]]
    # ],[         # LOSER BRACKET
    #   [[5,1], [1,2], [3,2], [6,9]],
    #   [[8,2], [1,2], [6,2], [1,3]],
    #   [[1,2], [3,1]],
    #   [[3,0], [1,9]],
    #   [[3,2]],
    #   [[4,2]]
    # ],[         # FINALS
    #   [[3,8], [1,2]],
    #   [[2,1]]
    # ]]

    results         = self.tournament.brackets["results"]
    opponent        = team == 0 ? 1 : 0
    result          = results[bracket][round][index]  rescue nil
    team_score      = result[team]                    rescue nil
    opponent_score  = result[opponent]                rescue nil

    if result.nil?
      # Reporting a score for a game that hasn't occurred yet. This will
      # happen if the opponent has not yet been decided.
      return -1
    elsif result == []
      # This is the position that we're reporting for.
      return [bracket, round, index, team]
    else
      win   = team_score > opponent_score
      team  = index.even?? 0 : 1

      if win
        # Stay in the same bracket, continue recursive traversal.
        return follow_bracket(bracket, round + 1, index / 2, team)
      else
        if bracket == 0
          # We're dropping into the losers bracket. Figure out where we're
          # supposed to go. Most algorithms involve dropping down to the
          # "opposite" index in the round.
          return follow_bracket(1, round, index, team)
        elsif bracket == 1
          # If this is a loss and we're in the loser's bracket, we have
          # nowhere else to go. Return -2 to represent a knockout.
          return -2
        elsif bracket == 2
          # TODO
        end
      end
    end
  end

  def increment_tournament_player_count
    self.tournament.increment_player_count(1)
  end

  def decrement_tournament_player_count
    self.tournament.increment_player_count(-1)
  end

  def set_username
    self.username = user.username
  end

  def update_tournament_brackets
    self.tournament.generate_brackets!
  end
end
