class Api::V1::BetterController < Api::ApplicationController
  before_filter :authenticate_user!

  respond_to :json

  def index
    last_stamp = nil
    time_spent = 0

    db = Sequel.postgres("pgshares", user: "postgres", host: "btc.pointgaming.com")
    db[:shares].select(:stamp).where("reason IS NULL AND username = ?", current_user.username).each do |share|
      if !last_stamp
        last_stamp = share[:stamp]
        next
      end

      time_between_shares = share[:stamp] - last_stamp
      if time_between_shares < 20.minutes
        time_spent += time_between_shares
      end

      last_stamp = share[:stamp]
    end

    render json: time_spent
  end
end
