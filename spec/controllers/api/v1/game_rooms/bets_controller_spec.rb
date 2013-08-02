require 'spec_helper'

describe Api::GameRooms::BetsController do
  render_views

  describe '#create' do
    let(:user) { Fabricate(:user) }
    let(:game) { Fabricate(:game) }
    let(:game_room) { Fabricate(:game_room, {game: game, owner: user}) }
    let(:request_params) { {game_room_id: game_room._id, api_token: node_api_token, user_id: user._id, format: :json} }

    context 'when user is logged in' do
      before(:each) do 
        user.update_attribute(:points, 100)
        sign_in(:user, user) 
      end

      context 'with valid params' do
        before(:each) do
          request_params[:bet] = {
            offerer_wager: 10, 
            match: {map: 'test-map', default_offerer_odds: '1:1' 
          }}
        end

        context 'with user self as chosen winner' do
          before(:each) do
            request_params[:bet][:offerer_choice] = 'player_1'
          end

          it 'expects bet created' do
            expect{ 
              post :create, request_params
            }.to change(Bet,:count).by(1)
          end

          it 'expects match created' do
            expect{ 
              post :create, request_params
            }.to change(Match,:count).by(1)
          end
        end
      end
    end
  end  
end