require 'spec_helper'

describe Api::Friends::FriendsController do
  let(:user) { Fabricate(:user) }
  let(:friend_user) { Fabricate(:user) }

  let(:request_params) {{
    id: defined?(game_room) ? game_room._id : nil, 
    api_token: node_api_token, 
    user_id: user._id, 
    format: :json 
  }}

  describe '#index' do
    let(:friend) { Friend.new }
    before(:each) do
      sign_in(:user, user) 
      friend.user = user
      friend.friend_user = friend_user
      friend.save!
    end

    it 'returns correct json' do
      get :index, request_params

      json = JSON.parse(response.body)
      expect(json.size).to eq(1)
      expect(json[0]['_id']).to eq(friend_user._id.to_s)
    end    
  end

  describe '#destroy' do
    before(:each) do
      sign_in(:user, user) 
    end  
    let(:request_params) { {api_token: node_api_token, user_id: user._id, format: :json} }  

    it 'expects friend destroyed' do
      friend = create_friend

      delete :destroy, request_params.merge(id: friend._id)
    end
  end
end

def create_friend
  friend = Friend.new :_id => 'test'
  friend.user = user
  friend.friend_user = friend_user
  friend.save! && friend
end