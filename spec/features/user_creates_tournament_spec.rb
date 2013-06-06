require 'spec_helper'

feature 'User creates tournament' do
  let(:user) { Fabricate(:user) }
  let(:tournament) { Fabricate(:tournament) }

  before(:each) { stub_user_sync_methods }
  after(:each) { unstub_user_sync_methods }

  before(:each) { sign_in(user.username, user.password) }

  scenario 'Creates a tournament with valid attributes' do
    visit '/user_tournaments/new'
    # FIXME: this is not meant to be a real test, yet.
    page.should have_content 'New Tournament'
  end

end
