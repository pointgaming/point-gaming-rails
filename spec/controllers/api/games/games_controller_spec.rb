require 'spec_helper'

describe Api::Games::GamesController do
  describe '#index' do
    let(:user) { Fabricate(:user) }
    let(:request_params) { {api_token: node_api_token, user_id: user._id, format: :json} }

    before(:each) do
      sign_in(:user, user) 
    end

    it 'returns correct json' do
      first_game = Fabricate(:game)
      second_game = Fabricate(:game) 

      get :index, request_params

      json = JSON.parse(response.body)
      expect(json.size).to eq(2)

      expect(json['games']).to_not be_nil
      json_game_ids = json['games'].map{|j| j['_id'] }.sort
      document_game_ids = [first_game,second_game].map{|g|g._id.to_s}.sort
      expect(json_game_ids).to eq(document_game_ids)
    end    
  end
end