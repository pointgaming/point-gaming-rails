require 'spec_helper'

describe Api::V1::UsersController do
  render_views

  describe '#show' do
    let(:user) { Fabricate(:user) }
    let(:request_params) { {api_token: node_api_token, format: :json, id: user._id} }

    context 'with valid request_params' do
      before(:each) do
        get :show, request_params
      end

      it 'response status is 200' do
        expect(response.status).to eq(200)
      end

      it 'returns correct json' do
        body = JSON.parse(response.body)
        expect(body).to include('user')
        user = body['user']
        expect(user).to eq(JSON.parse(user.to_json))
      end
    end
  end

  describe '#index' do
    let(:user1) { Fabricate(:user) }
    let(:user2) { Fabricate(:user) }
    let(:request_params) { {api_token: node_api_token, format: :json, user_id: [user1._id, user2._id]} }

    context 'with valid request_params' do
      before(:each) do
        get :index, request_params
      end

      it 'response status is 200' do
        expect(response.status).to eq(200)
      end

      it 'returns correct json' do
        body = JSON.parse(response.body)
        expect(body).to include('users')
        users = body['users']
        expect(users).to have(2).items
        expect( users.all?{|group| group.key?('team')} ).to be_true
      end
    end

    context 'with invalid request_params' do
      before(:each) do
        request_params.delete :user_id
        get :index, request_params
      end

      it 'response status is 422' do
        expect(response.status).to eq(422)
      end
    end
  end

end
