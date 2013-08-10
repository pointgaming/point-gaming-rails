require 'spec_helper'

describe Api::Disputes::DisputesController do
  describe '#show' do
    let(:user) { Fabricate(:user) }
    let(:dispute) { create_dispute }
    let(:request_params) { {api_token: node_api_token, user_id: user._id, format: :json, id: dispute.id} }

    before(:each) do
      sign_in(:user, user) 
    end

    it 'returns correct json' do
      get :show, request_params

      json = JSON.parse(response.body)
      expect(json['_id']).to_not be_nil
      expect(json['reason']).to_not be_nil
      expect(json['outcome']).to_not be_nil
    end    
  end
end

def create_dispute
  dispute = Dispute.new 
  dispute.reason = :incorrect_match_outcome
  dispute.state = 'new'
  dispute.messages << DisputeMessage.new(text: 'test', user: user)
  dispute.owner = user 
  dispute.match = Fabricate(:match)
  dispute.save! && dispute
end