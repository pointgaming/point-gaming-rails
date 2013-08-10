module Api
  module Games
    class ContextController < Api::ApplicationController
      before_filter :authenticate_user!

      respond_to :json
    end
  end
end