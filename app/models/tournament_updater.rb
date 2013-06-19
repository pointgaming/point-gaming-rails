class TournamentUpdater

  attr_accessor :tournament, :update_action, :update_params

  def initialize(tournament, update_params)
    self.tournament = tournament
    self.update_params = update_params
    self.update_action = determine_update_action
  end

  def save
    tournament.assign_attributes(update_params)
    after_assign
    tournament.save
  end

  def after_assign
    tournament.update_prizepool_total if update_action === :prize_pool
  end

  private

  def determine_update_action
    if update_params[:prizepool].present?
      :prize_pool
    else
      :edit
    end
  end

end
