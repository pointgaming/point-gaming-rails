class SeedsController < EngineController
  load_resource :tournament, find_by: :slug
  before_filter :ensure_tournament_editable_by_user

  def update
    params[:seeds].each_with_index do |player_id, i|
      @tournament.players.find(player_id).set(:seed, i) rescue nil
    end

    @tournament.generate_brackets!

    head :ok
  end

  def destroy
    @tournament.players.find(params[:id]).destroy

    head :ok
  end
end
