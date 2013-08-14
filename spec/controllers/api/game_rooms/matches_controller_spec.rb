require 'spec_helper'

describe Api::GameRooms::MatchesController do
  render_views

  describe '#index' do
    let(:user) { Fabricate(:user) }
    let(:taker) { Fabricate(:user) }
    let(:game) { Fabricate(:game) }
    let(:game_room) { create_game_room_with_owner(game, user) }

    let(:request_params) { {game_room_id: game_room._id, api_token: node_api_token, user_id: user._id, format: :json} }

    context 'when user is logged in' do
      before(:each) do 
        user.update_attribute(:points, 100)
        sign_in(:user, user) 
      end

      it 'returns correct json' do
      	match = create_match_with_game_room_and_players(game_room, user, taker)

        get :index, request_params
        json = JSON.parse(response.body)
        expect(json.size).to eq(1)

        json_ids = json.map{|j| j['_id'] }.sort
        document_ids = [match.id.to_s]
        expect(json_ids).to eq(document_ids)

        expect(json[0]['bets'].size).to eq(1)
        expect(json[0]['bets'][0]['outcome']).to eq('undetermined')
      end

      it 'returns only matches with undetermined bets' do
      	match = create_match_with_game_room_and_players(game_room, user, taker)
      	match.bets.each{|b| b.update_attribute(:outcome, 'cancelled')}

        get :index, request_params
        json = JSON.parse(response.body)
        expect(json.size).to eq(0)      	
      end

      it 'returns only current user matches' do
        sign_in(:user, Fabricate(:user))

        get :index, request_params
        json = JSON.parse(response.body)
        expect(json.size).to eq(0)      
      end
    end
  end

  describe '#update' do
    let(:user) { Fabricate(:user) }
    let(:taker) { Fabricate(:user) }
    let(:game) { Fabricate(:game) }
    let(:game_room) { create_game_room_with_owner(game, user) }

    let(:request_params) { {game_room_id: game_room._id, api_token: node_api_token, user_id: user._id, format: :json} }

    context 'when user is logged in' do
      before(:each) do 
        user.update_attribute(:points, 100)
        sign_in(:user, user) 
      end

      it 'updates match and bet workflow states' do
      	match = create_match_with_game_room_and_players(game_room, user, taker)
      	match.update_attribute :state, 'started'
      	bet = match.bets.first

        put :update, request_params.merge(id: match.id)
        match.reload
        bet.reload

        expect(match.state).to eq('finalized')
        expect(bet.outcome).to eq('offerer_won')
      end  

      it 'expects error when match not started' do
      	match = create_match_with_game_room_and_players(game_room, user, taker)
      	put :update, request_params.merge(id: match.id)
        expect(response.status).to eq(422)
      end   

      it 'expects error for non-participating user' do
        sign_in(:user, Fabricate(:user)) 
      	match = create_match_with_game_room_and_players(game_room, user, taker)
      	put :update, request_params.merge(id: match.id)
        expect(response.status).to eq(422)
      end
    end    
  end  
end

def create_match_with_game_room_and_players(game_room, player_1, player_2)
  match = Match.create!(
    game: game_room.game,
    room: game_room,
    map: 'test-map-00001',
    default_offerer_odds: '1:1',
    betting: false, 
    player_1: player_1, 
    player_2: player_2, 
    room_type: 'GameRoom'
  ) 
  bet = Bet.new(
    offerer_wager: 10, 
    match_hash: match.match_hash
  )
  bet.offerer_choice = match.player_1
  bet.taker_choice = match.player_2
  bet.match = match
  bet.offerer = player_1
  bet.taker = player_2
  bet.save!
  match
end

def create_game_room_with_owner(game, owner)
  Fabricate(:game_room, {game: game, owner: owner, betting_type: '1v1'})
end