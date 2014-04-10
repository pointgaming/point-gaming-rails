class TournamentsController < EngineController
  before_filter :ensure_tournament, except: [:index, :collaborated, :new, :create]
  before_filter :ensure_tournament_prizepool_required, only: [:prize_pool]
  before_filter :ensure_tournament_editable_by_user, only: [:edit, :update, :destroy]
  before_filter :ensure_tournament_started, only: [:brackets, :report_scores]

  def index
    @tournaments = Tournament.activated.order_by(signup_ends_at: :asc).all
    respond_with(@tournaments)
  end

  def collaborated
    @tournaments = Tournament.collaborated(current_user).all
  end

  def new
    @tournament = Tournament.new
  end

  def edit
  end

  def show
    @tournament = Tournament.find_by(slug: params[:id])
    respond_with(@tournament)
  end

  def create
    @tournament = Tournament.new(params[:tournament])
    @tournament.owner = current_user
    @tournament.save

    respond_with(@tournament, location: edit_tournament_path(@tournament.slug))
  end

  def update
    @tournament.update_attributes(params[:tournament])
    respond_with(@tournament, { action: default_update_action, 
                                location: next_tournament_path })
  end

  def destroy
    @tournament.destroy
    respond_with(@tournament, location: user_tournaments_path)
  end

  def prize_pool
  end

  def status
    @steps = @tournament.status_steps
  end

  def users
    @collaborators = @tournament.collaborators
    @invites = @tournament.invites
  end

  def brackets
    respond_to do |format|
      format.html
      format.json do
        brackets = @tournament.brackets
        brackets["teams"].map! { |p| p.map { |t| t.blank? || t == "BYE" ? "BYE" : @tournament.players.find(t).username } }
        render json: brackets
      end
    end
  end

  def report_scores
    player = @tournament.player_for_user(current_user)
    player.report_scores!(params[:mine], params[:his])

    redirect_to :back, notice: "Match scores submitted!"
  end

  private

  def default_update_action
    params[:tournament] && params[:tournament][:prizepool] ? :prize_pool : :edit
  end
end
