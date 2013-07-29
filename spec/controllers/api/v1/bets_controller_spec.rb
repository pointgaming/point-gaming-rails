require 'spec_helper'

describe Api::V1::BetsController do
  let(:user) { Fabricate(:user) }
  let(:request_params) { {id: game_room._id, api_token: node_api_token, user_id: user._id, format: :json} }
end