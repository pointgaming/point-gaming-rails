require 'spec_helper'

describe Api::Friends::FriendRequestsController do
  let(:user) { Fabricate(:user) }
  let(:friend_user) { Fabricate(:user) }

  let(:request_params) {{
    id: friend_request.id, 
    api_token: node_api_token, 
    user_id: user._id, 
    format: :json 
  }}

  describe '#show' do
    let(:friend_request) { FriendRequest.new }
    before(:each) do
      sign_in(:user, user) 
      friend_request.user = friend_user
      friend_request.friend_request_user = user
      friend_request.save!
    end

    it 'returns correct json' do
      get :show, request_params

      json = JSON.parse(response.body)
      expect(json['_id']).to eq(friend_request._id.to_s)
    end    
  end
end