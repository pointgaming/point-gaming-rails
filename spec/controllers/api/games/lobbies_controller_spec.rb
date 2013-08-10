require 'spec_helper'

describe Api::Games::LobbiesController do
  describe '#join' do
    let(:user) { Fabricate(:user) }
    let(:game) { Fabricate(:game) }
    let(:request_params) { {game_id: game.id, api_token: node_api_token, user_id: user._id, format: :json} }

    before(:each) do
      sign_in(:user, user) 
    end

    it 'expects lobby created' do
      expect{ 
        put :join, request_params
      }.to change(UserLobby,:count).by(1)
    end  
  end

  describe '#leave' do
    let(:user) { Fabricate(:user) }
    let(:game) { Fabricate(:game) }
    let(:request_params) { {game_id: game.id, api_token: node_api_token, user_id: user._id, format: :json} }

    before(:each) do
      sign_in(:user, user) 
    end

    it 'expects lobby created' do
      UserLobby.create user: user, game: game
      expect{ 
        put :leave, request_params
      }.to change(UserLobby,:count).by(-1)
    end  
  end  
end