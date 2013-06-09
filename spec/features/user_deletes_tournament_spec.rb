require 'spec_helper'

feature 'User deletes tournament' do
  let(:tournament) { Fabricate(:tournament) }

  context 'that they own' do
    before(:each) { sign_in(tournament.owner.username, "myawesomepassword") }

    it "is deleted successfully" do
      visit '/user_tournaments'
      expect{
        within "#tournament_#{tournament.id}" do
          click_link 'Destroy'
        end
      }.to change(Tournament,:count).by(-1)
    end
  end

end
