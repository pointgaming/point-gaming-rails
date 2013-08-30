require 'spec_helper'

describe Api::GameRooms::BetsController do
  render_views

  describe '#create' do
    let(:user) { Fabricate(:user) }
    let(:game) { Fabricate(:game) }
    let(:game_room) { create_game_room_with_owner(game, user) }
    let(:request_params) { {game_room_id: game_room._id, user_id: user._id, format: :json} }

    context 'when user is logged in' do
      before(:each) do 
        user.update_attribute(:points, 100)
        sign_in(:user, user) 
      end

      context 'with default offerer choice' do
        before(:each) do
          request_params[:bet] = bet_params
          request_params[:bet][:offerer_choice] = nil
        end

        it 'expects offerer as offerer choice' do
          post :create, request_params
          choice = assigns(:bet).offerer_choice
          expect(choice).to eq(user)
          expect(choice).to eq(assigns(:bet).match.player_1)
        end        
      end

      context 'with valid params' do
        before(:each) do
          request_params[:bet] = bet_params
        end

        context 'with 1v1 user betting' do
          it 'expects bet created' do
            expect{ 
              post :create, request_params
            }.to change(Bet,:count).by(1)
          end

          it 'expects match created' do
            expect{ 
              post :create, request_params

              expect(assigns(:match).default_offerer_odds).to eq(request_params[:bet][:offerer_odds])
            }.to change(Match,:count).by(1)
          end

          it 'returns correct json' do
            post :create, request_params
              
            json = JSON.parse(response.body)
            expect(json).to_not be_nil
            expect(json['_id']).to_not be_nil
            expect(json['offerer_wager']).to eq(bet_params[:offerer_wager])
            expect(json['offerer_choice_name']).to eq(user.username)

            expect(json['match']).to_not be_nil
            expect(json['match']['map']).to eq(bet_params[:match][:map])
            expect(json['match']['player_1_id']).to eq(user.id.to_s)
            expect(json['match']['player_1_type']).to eq('User')
          end 
        end

        context 'with team user betting' do
          let(:team) { Fabricate(:team, name: 'Test', tag: 'testing', points: 10) }
          let(:membership) { Fabricate(:team_member, user: user, team: team, rank: 'Member') }

          before(:each) do
            game_room.update_attribute :betting_type, 'team'
            user.update_attribute :team_id, team.id
            request_params[:bet][:match].merge!({team_size: 1})
          end

          it 'expects bet created' do
            expect{ 
              post :create, request_params
            }.to change(Bet,:count).by(1)
          end

          it 'returns correct json' do
            post :create, request_params
            user.reload
              
            json = JSON.parse(response.body)
            expect(json).to_not be_nil
            expect(json['_id']).to_not be_nil
            expect(json['offerer_wager']).to eq(bet_params[:offerer_wager])
            expect(json['offerer_choice_name']).to eq(user.team.name)

            expect(json['match']).to_not be_nil
            expect(json['match']['map']).to eq(bet_params[:match][:map])
            expect(json['match']['player_1_id']).to eq(user.team.id.to_s)
            expect(json['match']['player_1_type']).to eq('Team')
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

      json_bets_ids = json.map{|j| j['_id'] }.sort
      document_bet_ids = [Bet.first,Bet.last].map{|g|g._id.to_s}.sort
      expect(json_bets_ids).to eq(document_bet_ids)
    end

    context 'with bet scope filter' do
      before(:each) do 
        request_params[:scope] = 'unaccepted'

        taker = Fabricate(:user, {points: 100})
        bet = Bet.first
        bet.taker = taker
        bet.save!
      end

      it 'returns filtered bets' do
        bet = Bet.last
        bet.taker = nil
        bet.save(validate: false)

        get :index, request_params

        expect(assigns(:bets).size).to eq(1)
        expect(assigns(:bets).first).to eq(bet)
      end
    end    
  end

  describe '#destroy' do
    let(:user) { Fabricate(:user) }
    let(:offerer) { Fabricate(:user, {points: 100}) }
    let(:game) { Fabricate(:game) }
    let(:game_room) { create_game_room_with_owner(game, user) }
    let(:match) { create_match_with_game_room_and_player(game_room, offerer) }

    let(:request_params) { {game_room_id: game_room._id, id: bet._id, api_token: node_api_token, user_id: user._id, format: :json} }    

    context 'when user is offererer' do
      let(:bet) { create_bet_with_match_and_offerer(match, offerer) }

      before(:each) do
        sign_in(:user, user) 
        game_room.add_user_to_members!(user)
      end

      it 'expects bet destroyed' do
        delete :destroy, request_params

        expect(response.status).to eq(200)
        expect { bet.reload }.to raise_error(Mongoid::Errors::DocumentNotFound)
      end
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

  describe '#update' do
    let(:user) { Fabricate(:user) }
    let(:offerer) { Fabricate(:user, {points: 100}) }
    let(:game) { Fabricate(:game) }
    let(:game_room) { create_game_room_with_owner(game, user) }
    let(:match) { create_match_with_game_room_and_player(game_room, offerer) }

    let(:request_params) { {game_room_id: game_room._id, id: bet._id, api_token: node_api_token, user_id: user._id, format: :json} }        

    context 'when user is logged in' do
      before(:each) do 
        sign_in(:user, user) 
      end

      context 'with valid params' do
        let(:bet) { create_bet_with_match_and_offerer(match, offerer) }

        before(:each) do
          user.update_attribute(:points, 100)
          bet.taker = nil
          bet.save(validate: false)
        end

        it 'expects bet accepted' do
          put :update, request_params
          bet.reload

          expect(bet.outcome).to eq('accepted')
          expect(bet.match.player_2_id).to eq(user._id)
          expect(bet.taker_choice).to eq(bet.match.player_2)
        end    

        it 'starts match' do
          put :update, request_params

          expect(bet.match.reload.state).to eq('started')
        end     
      end

      context 'with invalid taker' do
        let(:bet) { create_bet_with_match_and_offerer(match, user) }

        before(:each) do
          sign_in(:user, user) 
        end

      end
    end    
  end
end

def bet_params
  {
    offerer_wager: 10, 
    offerer_choice: 'player_1',
    offerer_odds: '1:1',
    match: {map: 'test-map' }
  }
end

def create_game_room_with_owner(game, owner)
  Fabricate(:game_room, {game: game, owner: owner, betting_type: '1v1'})
end

def create_match_with_game_room_and_player(game_room, player)
  Fabricate(:match, {
    game: game_room.game,
    room: game_room,
    map: 'test-map-00001',
    default_offerer_odds: '1:1',
    betting: false, 
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
