require 'spec_helper'

describe Api::Streams::ContextController do
  describe 'ensure_stream' do
  	it 'expects stream assigned from id param' do
      stream = Stream.new
      stream.save(validate: false)
      controller.params = {id: stream.id}

      id = controller.send(:ensure_stream)
      expect(assigns(:stream)).to eq(stream)
  	end
  end
end