class SeedsController < EngineController
  before_filter :ensure_tournament
  before_filter :ensure_tournament_editable_by_user

  def update
    params[:seeds].each_with_index do |player_id, i|
      @tournament.players.find(player_id).update_attribute(:seed, i) rescue nil
    end

    head :ok
  end

  def destroy
    @tournament.players.find(params[:id]).destroy

    head :ok
  end
end
