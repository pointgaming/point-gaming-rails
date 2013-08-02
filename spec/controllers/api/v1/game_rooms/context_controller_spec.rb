require 'spec_helper'

describe Api::GameRooms::ContextController do
  describe 'game_room_id' do
  	it 'expects value from id param' do
      controller.params = {id: 'pass'}
      id = controller.send(:game_room_id)
      expect(id).to eq('pass')
  	end

  	it 'expects value from game_room_id param' do
      controller.params = {game_room_id: 'pass', id: 'fail'}
      id = controller.send(:game_room_id)
      expect(id).to eq('pass')
  	end
  end
end