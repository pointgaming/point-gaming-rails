class TournamentsController < EngineController
  load_resource :tournament, find_by: :slug, except: [:index, :collaborated, :create, :markdown]
  before_filter :ensure_tournament_editable_by_user, only: [:edit, :update]
  before_filter :ensure_tournament_owner, only: [:destroy]
  before_filter :ensure_tournament_started, only: [:brackets, :report_scores]

  def index
    @tournaments = Tournament.activated.asc(:starts_at).all
    respond_with(@tournaments)
  end

  def collaborated
    @tournaments = Tournament.collaborated(current_user).all
  end

  def new
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

    if @tournament.save
      flash.notice = "Thanks! Your tournament has been created. You will be notified when your payment details have been approved. After activation, you will no longer be able to edit these fields."
    end

    respond_with(@tournament, location: edit_tournament_path(@tournament.slug))
  end

  def update
    if @tournament.update_attributes(params[:tournament])
      flash.notice = "Tournament successfully updated."
    end

    redirect_to :back
  end

  def destroy
    @tournament.destroy
    flash.notice = "Tournament successfully destroyed."
    redirect_to :back
  end

  def brackets
    respond_to do |format|
      format.html
      format.json do
        brackets = @tournament.brackets
        brackets["teams"].map! { |p| p.map { |t| @tournament.players.unscoped.find(t).username } }
        render json: brackets
      end
    end
  end

  def report_scores
    player = @tournament.player_for_user(current_user)
    player.report_scores!(params[:mine], params[:his])

    redirect_to :back, notice: "Match scores submitted!"
  end

  def markdown
    @tournament = Tournament.new
    @tournament.details = params[:details]

    render partial: "/tournaments/widgets/rules"
  end

  private

  def default_update_action
    params[:tournament] && params[:tournament][:prizepool] ? :prize_pool : :edit
  end
end
