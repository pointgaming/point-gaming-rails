require 'spec_helper'

feature 'User edits tournament' do

  context 'that they created' do
    let(:tournament) { Fabricate(:tournament) }
    let(:user) { tournament.owner }

    before(:each) { sign_in(user.username, "myawesomepassword") }

    it "is updated successfully" do
      visit "/user_tournaments/#{tournament._id}/edit"

      new_tournament_name = "#{tournament.name} updated"

      fill_in :tournament_name, with: new_tournament_name
      click_button 'Update Tournament'

      expect(page).to have_content new_tournament_name
    end
  end

end
