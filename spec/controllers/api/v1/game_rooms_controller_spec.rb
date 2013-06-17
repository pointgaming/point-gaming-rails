require 'spec_helper'

describe Api::V1::GameRoomsController do
  let(:user) { Fabricate(:user) }
  let(:request_params) { {id: game_room._id, api_token: node_api_token, user_id: user._id, format: :json} }

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
