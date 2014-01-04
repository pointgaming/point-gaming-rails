class BetAcceptorService
  attr_reader :errors

  def initialize(opts)
    @bet = opts.fetch(:bet)
    @user = opts.fetch(:user)
    @errors = []
  end

  def accept
    bet.taker = user

    bet.save.tap do |saved|
      if saved
        log_user_bet
      else
        @errors.push(*bet.errors)
      end
    end
  end

  private

    attr_reader :bet, :user

    def log_user_bet
      amount = bet.bet_amount(user)
      description = 'Bet Accepted'
      UserBetLoggerService.new(user: user, bet: bet).
        log(amount, description)
    end
end
