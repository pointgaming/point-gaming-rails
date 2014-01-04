class BetCreatorService
  CHOICE_VALUES = ['player_1', 'player_2']

  attr_reader :errors

  def initialize(opts)
    @params = opts.fetch(:params)
    @match = opts.fetch(:match)
    @user = opts.fetch(:user)
    @errors = []
  end

  def create
    bet.save.tap do |saved|
      if saved
        log_user_bet
      else
        @errors.push(*bet.errors)
      end
    end
  end

  def bet
    @bet ||= new_bet
  end

  private

    attr_reader :params, :match, :user

    def log_user_bet
      amount = bet.bet_amount(user)
      description = 'Bet Created'
      UserBetLoggerService.new(user: user, bet: bet).
        log(amount, description)
    end

    def new_bet
      Bet.new(params).tap do |b|
        populate_bet(b)
      end
    end

    def populate_bet(bet)
      bet.offerer = user
      bet.match = match

      # if GameRoom bet: bet.offerer_odds = match.default_offerer_odds

      populate_choice(bet, :offerer)
      populate_choice(bet, :taker)
    end

    # sends offerer_choice or taker_choice to match
    def choice(context)
      value = params[:"#{context}_choice"]
      CHOICE_VALUES.include?(value) ? match.send(value) : nil
    end

    # sends offerer_choice=, offerer_choice_name= to bet
    # sends taker_choice=, taker_choice_name= to bet
    def populate_choice(bet, context)
      choice = choice(context)
      if choice
        bet.send("#{context}_choice=", choice)
        bet.send("#{context}_choice_name=", choice.display_name)
      end
    end
end
