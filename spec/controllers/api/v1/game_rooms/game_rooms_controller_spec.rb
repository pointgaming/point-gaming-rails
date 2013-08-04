require 'spec_helper'

describe Api::GameRooms::GameRoomsController do
  let(:user) { Fabricate(:user, {points: 100}) }
  let(:request_params) {{
    id: defined?(game_room) ? game_room._id : nil, 
    api_token: node_api_token, 
    user_id: user._id, 
    format: :json 
  }}

  describe '#create' do
    render_views
    let(:game) { Fabricate(:game) }

    context 'when user is logged in' do
      before(:each) do 
        sign_in(:user, user) 
      end

      context 'with valid params' do
        before(:each) do
          request_params[:game_room] = { name: 'test room', position: 101, game_id: game.id}
        end      

        it 'expects game room created' do
          expect{ 
            post :create, request_params
          }.to change(GameRoom,:count).by(1)
        end

        it 'returns correct json' do
          post :create, request_params
            
          json = JSON.parse(response.body)
          expect(json).to_not be_nil
          expect(json['owner_id'].to_s).to eq(user.id.to_s)
          expect(json['game_id'].to_s).to eq(game.id.to_s)
        end   
      end
    end
  end

  describe '#show' do
    render_views
    let(:game_room) { Fabricate(:game_room) }

    context 'with valid room' do
      before(:each) do
        get :show, request_params
      end

      it 'response status is 200' do
        expect(response.status).to eq(200)
      end

      it 'returns correct json' do
        json = JSON.parse(response.body)
        expect(json).to_not be_nil
        expect(json['_id'].to_s).to eq(game_room.id.to_s)
        expect(json['game_id'].to_s).to eq(game_room.game_id.to_s)
      end      
    end

    context 'with bets' do
      before(:each) do
        match = Fabricate(:match, {room: game_room, state: 'new' })
        game_room.matches << match
        bet = Fabricate(:bet, {offerer: user, match: match})
        game_room.save!
        get :show, request_params
      end

      it 'returns correct json' do
        json = JSON.parse(response.body)
        bets = json['bets']
        expect(bets.size).to eq(game_room.bets.size)

        first_bet = bets[0]
        expect(first_bet['_id']).to eq(game_room.bets.first._id.to_s)
        expect(first_bet['match']['_id']).to eq(game_room.bets.first.match._id.to_s)
      end
    end
  end

  describe '#update' do
    let(:user) { Fabricate(:user) }

    context 'when user is logged in and owner' do
      let(:game) { Fabricate(:game) }
      let(:game_room) { Fabricate(:game_room, {game: game, owner: user}) }
      let(:request_params) { {game_id: game._id, format: :json} }

      before(:each) { sign_in(:user, user) }

      context 'with valid params' do
        before(:each) do
          request_params[:id] = game_room.id
          request_params[:game_room] = {betting: false, betting_type: 'team'}
          
          put :update, request_params
          game_room.reload
        end

        it 'expects changes saved' do
          expect(game_room.betting_type).to eq('team')
          expect(game_room.betting).to eq(false)
        end
      end
    end
  end
  
  describe '#join' do
    let(:game_room) { Fabricate(:game_room) }

    context 'with invalid params' do

      context 'missing api_token' do
        before(:each) do
          request_params.delete :api_token
          put :join, request_params
        end
        it { expect(response.status).to eq(401) }
      end

      context 'invalid api_token' do
        before(:each) do
          request_params[:api_token] = 'rawr'
          put :join, request_params
        end
        it { expect(response.status).to eq(401) }
      end

      context 'missing user_id' do
        before(:each) do
          request_params.delete :user_id
          put :join, request_params
        end
        it { expect(response.status).to eq(403) }
      end

      context 'invalid user_id' do
        before(:each) do
          request_params[:user_id] = 12
          put :join, request_params
        end
        it { expect(response.status).to eq(404) }
      end

    end

    context 'with valid params' do

      context 'as a random user' do
        let!(:initial_member_count) { game_room.member_count }
        before(:each) { put :join, request_params }

        it 'response is successful' do
          expect(response).to be_success
        end

        it 'member_count is incremented by 1' do
          game_room.reload
          expect(game_room.member_count).to eq(initial_member_count + 1) 
        end

        it 'member_count is only incremented by 1 after multiple requests' do
          put :join, request_params
          put :join, request_params
          game_room.reload
          expect(game_room.member_count).to eq(initial_member_count + 1) 
        end
      end

    end
  end

  describe '#leave' do
    let(:game_room) { Fabricate(:game_room) }

    context 'with invalid params' do

      context 'missing api_token' do
        before(:each) do
          request_params.delete :api_token
          put :join, request_params
        end
        it { expect(response.status).to eq(401) }
      end

      context 'invalid api_token' do
        before(:each) do
          request_params[:api_token] = 'rawr'
          put :join, request_params
        end
        it { expect(response.status).to eq(401) }
      end

      context 'missing user_id' do
        before(:each) do
          request_params.delete :user_id
          put :join, request_params
        end
        it { expect(response.status).to eq(403) }
      end

      context 'invalid user_id' do
        before(:each) do
          request_params[:user_id] = 12
          put :join, request_params
        end
        it { expect(response.status).to eq(404) }
      end

    end

    context 'with valid params' do

      context 'as a random user' do
        let!(:initial_member_count) { game_room.member_count }
        before(:each) { put :leave, request_params }

        it 'response is successful' do
          expect(response).to be_success
        end

        it 'member_count remains the same' do
          game_room.reload
          expect(game_room.member_count).to eq(initial_member_count) 
        end
      end

      context 'as a member of the game room' do
        before(:each) do
          game_room.add_user_to_members!(user)
          game_room.add_user_to_members!(Fabricate(:user))
          game_room.reload
        end
        let!(:initial_member_count) { game_room.member_count }
        before(:each) { put :leave, request_params }

        it 'member_count is decremented by 1' do
          game_room.reload
          expect(game_room.member_count).to eq(initial_member_count - 1) 
        end

        it 'member_count is only decremented by 1 after multiple requests' do
          put :leave, request_params
          put :leave, request_params
          game_room.reload
          expect(game_room.member_count).to eq(initial_member_count - 1) 
        end

      end

    end
  end

end
