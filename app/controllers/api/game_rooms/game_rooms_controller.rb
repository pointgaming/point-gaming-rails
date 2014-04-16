module Api
  module GameRooms
    class GameRoomsController < Api::GameRooms::ContextController
      before_filter :authenticate_user!, only: [:create, :update]
      before_filter :authenticate_node_api!, except: [:create, :update, :take_over, :can_take_over, :can_hold, :team_bot, :settings, :show]
      before_filter :ensure_user, only: [:join, :leave]
      before_filter :ensure_not_banned, only: [:join, :update]
      before_filter :ensure_params, only: [:create, :update]
      before_filter :check_owner_params, only: [:update]
      skip_before_filter :ensure_game_room, only: [:create]

      def show
        @game_room.matches = @game_room.pending_matches
        json = @game_room.as_json(:methods => [:bets], include: [:members, :team])

        respond_with(json)
      end

      def create
        @game_room = GameRoom.new(params[:game_room])
        @game_room.game = @game_room.game
        @game_room.owner = current_user
        @game_room.save

	respond_with :api, @game_room
      end

      def update
	update_hash = params[:game_room]
	admins_ids = update_hash[:admins]
	team_bot_present = update_hash[:is_team_bot_placed]
	update_hash.delete(:admins)
	update_hash.delete(:is_team_bot_placed)
        update_hash.delete(:game_id)
        update_hash.delete(:owner_id)
        @game_room.owner = @owner unless @owner.nil?
	if team_bot_present && @game_room.is_free?
	  @game_room.hold(current_user) if current_user.can_hold?(@game_room)
	elsif !team_bot_present && !@game_room.is_free?
	  @game_room.team_bot.delete
	end
	@game_room.admins = []
	if admins_ids.present?
	  admins_ids.each do |admin_id|
	    admin = User.where(id: admin_id).first
	    @game_room.admins << admin unless admin.eql?(@game_room.owner)
	  end
	end
        @game_room.update_attributes(update_hash)
        respond_with :api, @game_room
      end

      def destroy
        @game_room.destroy
        respond_with :api, @game_room
      end

      def join
        @game_room.add_user_to_members!(@user)
        respond_with(@game_room)
      end

      def leave
        @game_room.remove_user_from_members!(@user)
        respond_with(@game_room)
      end

      def take_over
        @game_room = GameRoom.find params[:id]
        if @game_room && !current_user.eql?(@game_room.owner) && current_user.can_take_over?(@game_room)
          position = @game_room.position
          @game_room.take_over current_user
          @new_game_room = GameRoom.where(position: position).first
          respond_with :api, @new_game_room
        else
          respond_with({ errors: ["You cannot take this room over"] })
        end
      end

      def can_take_over
        respond_with({ answer: current_user.can_take_over?(@game_room) })
      end

      def can_hold
	respond_with({ answer: current_user.can_hold?(@game_room), is_team_bot_placed: !@game_room.is_free? })
      end

      def team_bot
	team_bot = @game_room.team_bot
	answer = team_bot.present? ? { name: team_bot.team.name, points: team_bot.team.points } : { errors: 'No team bot found' }
	respond_with(answer)
      end

      def settings
	answer = { can_hold: current_user.can_hold?(@game_room), is_team_bot_placed: !@game_room.is_free?, is_advertising: @game_room.is_advertising }
	respond_with answer
      end

    protected

      def ensure_user
        if params[:user_id].present?
          @user = User.find params[:user_id]
        else
          respond_with({errors: ["Missing user_id parameter"]}, status: 403)
        end
      end

      def ensure_params
        raise ::UnprocessableEntity, "Missing game_room parameter" if params[:game_room].blank?
      end

      def check_owner_params
        return unless params[:game_room][:owner_id]

        @owner = User.find(params[:game_room][:owner_id])
        raise ::UnprocessableEntity, "Invalid owner_id. A user with that id was not found." unless @owner
      end

      def ensure_not_banned
	 @user = current_user unless @user
	 game = @game_room.present? ? @game_room.game : Game.where(id: params[:game_room][:game_id]).first
         is_banned = @user.is_banned_for? game
	 if is_banned
	   @game_room.errors[:base] << "User is banned"
	   respond_with :api, @game_room
	 end
      end
    end
  end
end
