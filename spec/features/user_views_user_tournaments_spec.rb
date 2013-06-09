require 'spec_helper'

feature 'User views user_tournaments' do
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
