require 'spec_helper'

describe Api::Streams::StreamsController do
  render_views

  describe '#show' do
    let(:stream) { Fabricate(:stream, {name: 'Test', slug: 'test'}) }
    let(:request_params) { {api_token: node_api_token, format: :json} }

    context 'with valid params' do
      before(:each) do
        request_params[:id] = stream.id
      end

      it 'returns correct json' do
        get :show, request_params

        json = JSON.parse(response.body)
        expect(json['_id'].to_s).to eq(stream.id.to_s)
      end      
    end
  end
end