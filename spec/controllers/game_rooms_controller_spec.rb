require 'spec_helper'

describe GameRoomsController do
  render_views

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

  describe '#index' do
    let(:user) { Fabricate(:user) }
    let(:game) { Fabricate(:game) }
    let(:request_params) { {game_id: game._id, format: :json} }

    context 'when user is not logged in' do
      before(:each) { get :index, request_params }
      it { expect(response.status).to eq(401) }
    end

    context 'when user is logged in' do
      before(:each) { sign_in(:user, user) }

      context 'with invalid params' do
        before(:each) do
          request_params.delete(:game_id)
          get :index, request_params
        end
        it { expect(response.status).to eq(422) }
      end

      context 'with valid params' do
        before(:each) { get :index, request_params }
        it { expect(response).to be_success }
      end

      context 'game room has members' do
        before(:each){ 2.times { create_game_room_with_members(game: game) } }
        before(:each) { get :index, request_params }

        it { expect(response).to be_success }

        it 'returns correct json' do
          body = JSON.parse(response.body)
          expect(body).to include('game_rooms')
          game_rooms = body['game_rooms']
          expect(game_rooms).to have(2).items
          expect( game_rooms.all?{|group| group.key?('members')} ).to be_true
        end
      end
    end

  end

end

def create_game_room_with_members(options={})
  game_room = Fabricate(:game_room, options)
  game_room.add_user_to_members!(Fabricate(:user))
  game_room.add_user_to_members!(Fabricate(:user))
  game_room
end
