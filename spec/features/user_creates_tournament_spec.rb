require 'spec_helper'

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
