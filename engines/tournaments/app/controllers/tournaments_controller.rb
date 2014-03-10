class TournamentsController < EngineController
  before_filter :ensure_tournament, except: [:index, :collaborated, :new, :create]
  before_filter :ensure_tournament_prizepool_required, only: [:prize_pool]
  before_filter :ensure_tournament_editable_by_user, only: [:edit, :update, :destroy]
  before_filter :ensure_tournament_started, only: [:brackets]

  respond_to :html, :json

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

    respond_with(@tournament, location: edit_tournament_path(@tournament.id))
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

  def seeds
    if request.put?
      params[:seeds] = [] if params[:seeds].blank?

      players = params[:seeds].map { |s| @tournament.players.find(s) } rescue false

      if players
        @tournament.seeds = params[:seeds]
        @tournament.save
        @tournament.generate_brackets!
      end

      head :ok
    end
  end

  def brackets
    respond_to do |format|
      format.html
      format.json do
        brackets = @tournament.brackets
        brackets["teams"].map! { |p| p.map { |t| t.blank? || t == "BYE" ? "BYE" : @tournament.players.find(t).user.username } }
        render json: brackets
      end
    end
  end

  private

  def default_update_action
    params[:tournament] && params[:tournament][:prizepool] ? :prize_pool : :edit
  end
end
