require 'spec_helper'

describe MatchesController do
  render_views

  describe '#create' do
    let(:user) { Fabricate(:user) }
    let(:game) { Fabricate(:game) }

    let(:player1) { Fabricate(:user) }
    let(:player2) { Fabricate(:user) }

    before(:each) { sign_in(:user, user) }

    context 'when user is logged in and owner' do
      let(:game_room) { Fabricate(:game_room, {game: game, owner: user}) }
      let(:request_params) { {game_room_id: game_room._id, api_token: node_api_token, user_id: user._id, format: :json} }

      before(:each) do
        sign_in(:user, user)
        request_params[:match] = {
          game_id: game_room.game_id,
          map: 'test-map-00001',
          default_offerer_odds: '1:1',
          betting: false, 
          betting_type: 'team', 
          player_1_id: user._id, 
          player_2_id: player2._id,
          player_1_type: 'User',
          player_2_type: 'User'
        }
      end

      it 'response status is 201' do
        post :create, request_params
        expect(response.status).to eq(201)
      end

      it 'expects match created' do
        expect{ 
          post :create, request_params
          assigns(:room).should eq(game_room)
        }.to change(Match,:count).by(1)
        expect(assigns(:room).match).to_not be_nil
	    end

      it 'returns correct json' do
        post :create, request_params
        match = JSON.parse(response.body)
        
        expect(match['_id'].to_s).to eq(assigns(:room).match._id.to_s)
        expect(match['room_type']).to eq('GameRoom')
        expect(match['state']).to eq('new')
        expect(match['default_offerer_odds']).to eq( request_params[:match][:default_offerer_odds] )
        expect(match['map']).to eq( request_params[:match][:map] )
      end
    end

    context 'when user is logged in and member' do
    end    
  end
end