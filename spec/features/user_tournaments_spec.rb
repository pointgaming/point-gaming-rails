require 'spec_helper'

def fill_in_tournament_form(tournament)
  fill_in :tournament_name, with: tournament.name
  fill_in :tournament_slug, with: tournament.slug
  fill_in :tournament_stream_slug, with: tournament.stream_slug
  fill_in :tournament_signup_start_datetime, with: ldate(tournament.signup_start_datetime)
  fill_in :tournament_signup_end_datetime, with: ldate(tournament.signup_end_datetime)
  fill_in :tournament_check_in_start_datetime, with: ldate(tournament.check_in_start_datetime)
  fill_in :tournament_check_in_end_datetime, with: ldate(tournament.check_in_end_datetime)
  fill_in :tournament_start_datetime, with: ldate(tournament.start_datetime)
  fill_in :tournament_player_limit, with: tournament.player_limit
  select_option :tournament_format, tournament.format
  select_option :tournament_type, tournament.type
  select_option :tournament_game_id, tournament.game_id
  select_option :tournament_game_type_id, tournament.game_type_id
  fill_in :tournament_maps, with: tournament.maps
  fill_in :tournament_details, with: tournament.details
end

shared_examples_for 'current_status_row' do
  it "status row is marked as incompleted" do
    status_row = find('tr', text: status_text)
    expect(status_row[:class]).to include('warning')
  end
end

shared_examples_for 'incompleted_status_row' do
  it "status row is marked as incompleted" do
    status_row = find('tr', text: status_text)
    expect(status_row[:class]).to include('error')
  end
end

shared_examples_for 'completed_status_row' do
  it "status row is marked as completed" do
    status_row = find('tr', text: status_text)
    expect(status_row[:class]).to include('success')
  end
end

feature 'User Tournaments' do
  let(:tournament) { Fabricate(:tournament) }
  let(:user) { Fabricate(:user) }
  let(:game_type) { Fabricate(:game_type) }

  describe 'User views user_tournaments#index' do
    it "lists tournaments they created" do
      sign_in(tournament.owner)

      visit "/user_tournaments"

      expect(page).to have_content tournament.name
    end

    it "doesn't list tournaments created by another user" do
      tournament

      sign_in(user)

      visit "/user_tournaments"

      expect(page).to_not have_content tournament.name
    end
  end

  describe 'User creates tournament' do
    let(:tournament) { Fabricate.build(:tournament, game_type: game_type, game: game_type.game) }
    before(:each) { sign_in(user) }
    before(:each) { game_type }

    context 'with valid attributes' do
      it "adds a tournament to the database", js: true do
        visit '/user_tournaments/new'
        expect {
          fill_in_tournament_form(tournament)
          click_button 'Next'
        }.to change(Tournament, :count).by(1)
      end
    end

    context 'with invalid attributes' do
      it "doesn't add a tournament to the database" do
        visit '/user_tournaments/new'
        expect {
          click_button 'Next'
        }.to change(Tournament, :count).by(0)
      end
    end
  end

  describe 'User edits tournament' do
    context 'that they created' do
      before(:each) { sign_in(tournament.owner) }

      it "is updated successfully" do
        visit "/user_tournaments/#{tournament._id}/edit"

        new_tournament_name = "#{tournament.name} updated"

        fill_in :tournament_name, with: new_tournament_name
        click_button 'Next'

        expect(page).to have_content new_tournament_name
      end
    end
  end

  describe 'User deletes tournament' do
    context 'that they own' do
      before(:each) { sign_in(tournament.owner) }

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

  describe 'User edits tournament prize_pool' do
    context 'user owns tournament' do
      before(:each) do
        sign_in(tournament.owner)

        visit "/user_tournaments/#{tournament._id}/edit"
        click_link 'Prize Pool'
      end

      context 'with valid attributes' do
        it "is updated successfully" do
          within 'form[data-hook=prize-pool-form]' do
            fill_in "tournament_prizepool_1", with: '5'
            fill_in "tournament_prizepool_2", with: '5'
            click_button 'Next'
          end

          expect(page).to have_selector 'form[data-hook=payment-form]'
        end

        it "displays prize pool total", js: true do
          within 'form[data-hook=prize-pool-form]' do
            fill_in "tournament_prizepool_1", with: '5'
            fill_in "tournament_prizepool_2", with: '1'
          end

          total_container = page.find('[data-hook=prize-pool-total]')
          expect(total_container).to have_content '$6.00'
        end
      end

      context 'with invalid attributes' do
        it "displays errors with non-numeric input" do
          within 'form[data-hook=prize-pool-form]' do
            fill_in "tournament_prizepool_1", with: 'a'
            click_button 'Next'
          end

          expect(page).to have_selector 'div.alert-error'
        end

        it "displays calculated prize pool total" do
          within 'form[data-hook=prize-pool-form]' do
            fill_in "tournament_prizepool_1", with: '12'
            fill_in "tournament_prizepool_2", with: 'a'
            click_button 'Next'
          end

          total_container = page.find('[data-hook=prize-pool-total]')
          expect(total_container).to have_content '$12.00'
        end
      end
    end
  end

  describe 'User views status' do
    let (:created_status) { 'Tournament created' }
    let (:prizepool_required_status) { 'Prizepool locked in' }
    let (:payment_submitted_status) { 'information submitted' }
    let (:verifying_payment_status) { 'Verifying payment' }
    let (:activated_status) { 'Activated' }
    before { sign_in(tournament.owner) }

    describe 'by clicking the status link from the edit page' do
      before do
        visit "/user_tournaments/#{tournament._id}/status"
        click_link 'Status'
      end

      it 'renders the status page' do
        expect(page).to have_selector "#status-widget"
      end
    end

    context 'Tournament was just created' do
      before do
        visit "/user_tournaments/#{tournament._id}/status"
      end

      it_behaves_like 'completed_status_row' do
        let (:status_text) { created_status }
      end

      it_behaves_like 'current_status_row' do
        let (:status_text) { prizepool_required_status }
      end

      it_behaves_like 'incompleted_status_row' do
        let (:status_text) { payment_submitted_status }
      end
      it_behaves_like 'incompleted_status_row' do
        let (:status_text) { verifying_payment_status }
      end
      it_behaves_like 'incompleted_status_row' do
        let (:status_text) { activated_status }
      end
    end

    context 'Tournament prize pool is locked in' do
      before do
        tournament.update_attributes prizepool: {"1" => "5"}
        visit "/user_tournaments/#{tournament._id}/status"
      end

      it_behaves_like 'completed_status_row' do
        let (:status_text) { created_status }
      end
      it_behaves_like 'completed_status_row' do
        let (:status_text) { prizepool_required_status }
      end

      it_behaves_like 'current_status_row' do
        let (:status_text) { payment_submitted_status }
      end

      it_behaves_like 'incompleted_status_row' do
        let (:status_text) { verifying_payment_status }
      end
      it_behaves_like 'incompleted_status_row' do
        let (:status_text) { activated_status }
      end
    end

    context 'Tournament payment is submitted' do
      before do
        tournament.update_attributes prizepool: {"1" => "5"}
        Fabricate(:tournament_payment_credit_card, tournament: tournament)
        visit "/user_tournaments/#{tournament._id}/status"
      end

      it_behaves_like 'completed_status_row' do
        let (:status_text) { created_status }
      end
      it_behaves_like 'completed_status_row' do
        let (:status_text) { prizepool_required_status }
      end
      it_behaves_like 'completed_status_row' do
        let (:status_text) { payment_submitted_status }
      end

      it_behaves_like 'current_status_row' do
        let (:status_text) { verifying_payment_status }
      end

      it_behaves_like 'incompleted_status_row' do
        let (:status_text) { activated_status }
      end
    end

  end

end
