module Api
  module Users
    class UsersController < Api::Users::ContextController
      before_filter :authenticate_user_or_api_call!
      before_filter :ensure_params, only: [:index]
      before_filter :ensure_user, except: [:index]

      def index
        @users = User.in(_id: params[:user_id]).all
        respond_with :api, @users
      end

      def show
        render json: { user: @user.as_json({ include: [:group, :team], except: [:password] }) }
      end

      def add_to_team
        team_id = params[:team_id]
        game_room_id = params[:game_room_id]
        user = User.where(id: params[:id]).first
        team = Team.where(id: team_id).first
        game_room = GameRooms.where(id: game_room_id).first
        user_team = UserTeam.where(user: user, game_room: game_room).first
        if user_team.blank? && current_user.as_team_member.can_edit_team?
          user_team = UserTeam.create(user: user, team: team, owner: current_user, game_room: game_room)
        end
        team_json = user.team.as_json
        respond_with(team_json)
      end

      def remove_from_team
        team_id = params[:team_id]
        user_id = params[:id]
        if current_user.as_team_member.can_edit_team?
          user_team = UserTeam.where(user_id: user_id, team_id: team_id).first
          user_team.delete if user_team.present?
        end
        user = User.where(id: user_id).first
        respond_with :api, user.team
      end
    end
  end
end
