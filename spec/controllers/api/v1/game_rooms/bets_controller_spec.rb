require 'spec_helper'

describe Api::GameRooms::BetsController do
  render_views

  describe '#create' do
    let(:user) { Fabricate(:user) }
    let(:game) { Fabricate(:game) }
    let(:game_room) { Fabricate(:game_room, {game: game, owner: user, betting_type: '1v1'}) }
    let(:request_params) { {game_room_id: game_room._id, api_token: node_api_token, user_id: user._id, format: :json} }

    context 'when user is logged in' do
      before(:each) do 
        user.update_attribute(:points, 100)
        sign_in(:user, user) 
      end

      context 'with valid params' do
        before(:each) do
          request_params[:bet] = bet_params
        end

        context 'with 1v1 user betting' do
          it 'expects bet created' do
            expect{ 
              post :create, request_params

              json = JSON.parse(response.body)
              expect(json['_id']).to_not be_nil
            }.to change(Bet,:count).by(1)
          end

          it 'expects match created' do
            expect{ 
              post :create, request_params
            }.to change(Match,:count).by(1)
          end
        end
      end

      context 'with invalid request on existing match' do
        let(:match) { create_match_with_game_room_and_player(game_room, user) }
        let(:bet) { create_bet_with_match_and_offerer(match, user) }

        before(:each) do
          game_room.match = match 
          game_room.save!
          request_params[:bet] = bet_params
        end        

        it 'expects no match created' do
          expect{ 
            post :create, request_params
          }.to change(Match,:count).by(0)
          expect(response.status).to eq(422)
        end
      end

      context 'with game room betting disabled' do
        before(:each) do
          game_room.betting = false
          game_room.save!
          request_params[:bet] = bet_params
        end

        it 'expects no bet created' do
          expect{ 
            post :create, request_params
          }.to change(Bet,:count).by(0)
          expect(response.status).to eq(422)
        end              
      end
    end
  end  

  describe '#index' do
    let(:user) { Fabricate(:user) }
    let(:offerer) { Fabricate(:user, {points: 100}) }
    let(:game) { Fabricate(:game) }
    let(:game_room) { create_game_room_with_owner(game, user) }
    let(:request_params) { {game_room_id: game_room._id, api_token: node_api_token, user_id: user._id, format: :json} }

    before(:each) do
      sign_in(:user, user) 
      2.times do 
        match = create_match_with_game_room_and_player(game_room, offerer)
        bet = create_bet_with_match_and_offerer(match, offerer)
      end
    end

    it 'returns correct json' do
      get :index, request_params

      json = JSON.parse(response.body)
      expect(json.size).to eq(2)
    end
  end

  describe '#show' do
    let(:user) { Fabricate(:user) }
    let(:offerer) { Fabricate(:user, {points: 100}) }
    let(:game) { Fabricate(:game) }
    let(:game_room) { create_game_room_with_owner(game, user) }
    let(:match) { create_match_with_game_room_and_player(game_room, offerer) }
    let(:bet) { create_bet_with_match_and_offerer(match, offerer) }

    let(:request_params) { {game_room_id: game_room._id, id: bet._id, api_token: node_api_token, user_id: user._id, format: :json} }

    context 'when user is game room member' do
      before(:each) do
        sign_in(:user, user) 
        game_room.add_user_to_members!(user)
      end

      it 'returns correct json' do
        expect{ 
          get :show, request_params

          json = JSON.parse(response.body)
          expect(json['_id'].to_s).to eq(bet._id.to_s)
          expect(json['match']['_id'].to_s).to eq(match._id.to_s)
        }.to change(Bet,:count).by(1)
      end      
    end
  end
end

def bet_params
  {
    offerer_wager: 10, 
    offerer_choice: 'player_1',
    match: {map: 'test-map', default_offerer_odds: '1:1' 
  }}
end

def create_game_room_with_owner(game, owner)
  Fabricate(:game_room, {game: game, owner: offerer, betting_type: '1v1'})
end

def create_match_with_game_room_and_player(game_room, player)
  Fabricate(:match, {
    game: game_room.game,
    room: game_room,
    map: 'test-map-00001',
    default_offerer_odds: '1:1',
    betting: false, 
    betting_type: 'team', 
    player_1_id: player._id, 
    player_1_type: 'User',
    room_type: 'GameRoom'
  }) 
end

def create_bet_with_match_and_offerer(match, offerer)
  Fabricate(:bet, { 
    offerer_wager: 10, 
    offerer: offerer,
    match: match,
    match_hash: match.match_hash
  }) 
end
