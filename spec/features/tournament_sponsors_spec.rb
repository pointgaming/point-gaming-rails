require 'spec_helper'

feature 'Tournament Sponsors' do
  context 'When editing an existing tournament', js: true do
    let(:tournament) { Fabricate(:tournament) }
    let(:user) { tournament.owner }

    let(:new_sponsor) { Fabricate.build(:tournament_sponsor, tournament: tournament) }
    before(:each) { sign_in(user.username, "myawesomepassword") }

    describe 'A user can add a new sponsors' do
      it 'is created successfully' do
        visit edit_user_tournament_path(tournament)

        hover_over_jquery_selector('#new_sponsor')

        within '#new_sponsor' do
          click_link 'New'
        end

        within('#ajax-modal') do
          fill_in 'Name', with: new_sponsor.name
          fill_in 'Url', with: new_sponsor.url
          attach_file 'Image', File.join(Rails.root, 'spec', 'fabricators', 'images', 'image.jpg')
          fill_in 'Sort order', with: new_sponsor.sort_order
          click_button 'Create Sponsor'
        end

      end
    end

    describe 'A user can edit an existing sponsor' do
      let!(:tournament_sponsor) { Fabricate(:tournament_sponsor, tournament: tournament) }

      it "is updated successfully" do
        new_url = 'http://chrisbankston.com'
        new_sponsor = Fabricate.build(:tournament_sponsor, tournament: tournament, url: new_url)

        visit edit_user_tournament_path(tournament)

        hover_over_jquery_selector(tournament_container_selector(tournament_sponsor))

        within tournament_container_selector(tournament_sponsor) do
          click_link 'Edit'
        end

        within('#ajax-modal') do
          fill_in 'Name', with: new_sponsor.name
          fill_in 'Url', with: new_sponsor.url
          attach_file 'Image', File.join(Rails.root, 'spec', 'fabricators', 'images', 'image.jpg')
          fill_in 'Sort order', with: new_sponsor.sort_order
          click_button 'Update Sponsor'
        end

        within tournament_container_selector(tournament_sponsor) do
          expect(page).to have_xpath("//a[@href=\"#{new_url}\"]")
        end
      end
    end
  end
end

def tournament_container_selector(sponsor)
  "#sponsor_#{sponsor._id}"
end
