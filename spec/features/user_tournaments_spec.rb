require 'spec_helper'


feature 'User views user_tournaments#index' do
  let(:tournament) { Fabricate(:tournament) }

  it "lists tournaments they created" do
    sign_in(tournament.owner.username, "myawesomepassword")

    visit "/user_tournaments"

    expect(page).to have_content tournament.name
  end

  it "doesn't list tournaments created by another user" do
    tournament
    user = Fabricate(:user)

    sign_in(user.username, user.password)

    visit "/user_tournaments"

    expect(page).to_not have_content tournament.name
  end
end

feature 'User creates tournament' do
  let(:user) { Fabricate(:user) }
  let(:game_type) { Fabricate(:game_type) }
  let(:tournament) { Fabricate.build(:tournament, game_type: game_type, game: game_type.game) }

  before(:each) { sign_in(user.username, user.password) }

  context 'with valid attributes' do
    it "adds a tournament to the database", js: true do
      game_type

      visit '/user_tournaments/new'

      expect {
        fill_in :tournament_name, with: tournament.name
        fill_in :tournament_slug, with: tournament.slug
        fill_in :tournament_signup_start_datetime, with: ldate(tournament.signup_start_datetime)
        fill_in :tournament_signup_end_datetime, with: ldate(tournament.signup_end_datetime)
        fill_in :tournament_start_datetime, with: ldate(tournament.start_datetime)
        fill_in :tournament_player_limit, with: tournament.player_limit
        select_option :tournament_format, tournament.format
        select_option :tournament_type, tournament.type
        select_option :tournament_game_id, tournament.game_id
        select_option :tournament_game_type_id, tournament.game_type_id
        fill_in :tournament_maps, with: tournament.maps
        fill_in :tournament_details, with: tournament.details
        click_button 'Create Tournament'
      }.to change(Tournament, :count).by(1)
    end
  end

  context 'with invalid attributes' do
    it "doesn't add a tournament to the database", js: true do
      game_type

      visit '/user_tournaments/new'

      expect {
        click_button 'Create Tournament'
      }.to change(Tournament, :count).by(0)
    end
  end
end

feature 'User edits tournament' do
  let(:tournament) { Fabricate(:tournament) }

  context 'that they created' do
    before(:each) { sign_in(tournament.owner.username, "myawesomepassword") }

    it "is updated successfully" do
      visit "/user_tournaments/#{tournament._id}/edit"

      new_tournament_name = "#{tournament.name} updated"

      fill_in :tournament_name, with: new_tournament_name
      click_button 'Update Tournament'

      expect(page).to have_content new_tournament_name
    end
  end
end

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
