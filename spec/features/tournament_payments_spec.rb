require 'spec_helper'

shared_examples_for 'source_for_tournament_payment_form' do
  context 'with valid input' do
    it 'takes the user to the collaborator form after payment', :js => true do
      within 'form[data-hook=payment-form]' do
        choose payment_source_option
        fill_out_form
        click_button 'Next'
      end
      expect(page).to have_selector 'form[data-hook=collaborator-form]'
    end
  end

  context 'with invalid input' do
    before do
      within 'form[data-hook=payment-form]' do
        choose payment_source_option
        click_button 'Next'
      end
    end

    it 'bank account information form is visible', :js => true do
      expect(page).to have_selector form_container
    end

    it 'displays an error to the user' do
      expect(page).to have_selector 'div.alert-error'
    end
  end
end

feature 'Tournament Payments' do
  let(:tournament) { Fabricate(:tournament) }

  describe 'User goes to the Pay page' do

    context 'tournament has prizepool configured' do
      before do
        tournament.update_attributes prizepool: {"1" => "5"}
        sign_in(tournament.owner)
        visit "/user_tournaments/#{tournament._id}/payments/new"
      end

      it 'after clicking the "Pay" tab when editing a tournament' do
        sign_in(tournament.owner)
        visit "/user_tournaments/#{tournament._id}/edit"
        click_link 'Pay'
        expect(page).to have_selector 'form[data-hook=payment-form]'
      end

      it "displays prize pool total" do
        total_container = page.find('[data-hook=prize-pool-total]')
        expect(total_container).to have_content '$5.00'
      end

      context 'Bank Account option' do
        it_behaves_like 'source_for_tournament_payment_form' do
          let (:payment_source_option) { 'Bank Transfer' }
          let (:form_container) { payment_source_fields_css(:bank_account) }
          let (:fill_out_form) do
            within form_container do
              fill_in "account number", with: '123456789123'
              fill_in "routing number", with: '123456789'
            end
          end
        end
      end

      context 'Credit Card option' do
        it_behaves_like 'source_for_tournament_payment_form' do
          let (:payment_source_option) { 'Credit Card' }
          let (:form_container) { payment_source_fields_css(:credit_card) }
          let (:fill_out_form) do
            within form_container do
              fill_in "Name on Card", with: 'James Doe'
              fill_in "Card Number", with: '4111111111111111'
              fill_in "Expiration Month", with: '06'
              fill_in "Expiration Year", with: '13'
              fill_in "Verification Code", with: '213'
              fill_in "Address 1", with: '123 Big Walk Way'
              fill_in "Address 2", with: 'Apt 1'
              fill_in "City", with: 'Texas City'
              fill_in "State", with: 'Texas'
              fill_in "Zip", with: '77591'
            end
          end
        end
      end

      context 'PayPal option' do
        it_behaves_like 'source_for_tournament_payment_form' do
          let (:payment_source_option) { 'PayPal' }
          let (:form_container) { payment_source_fields_css(:paypal) }
          let (:fill_out_form) do
            within form_container do
              fill_in "Paypal email", with: 'james@doeman.com'
            end
          end
        end
      end
    end
  end

  def payment_source_css(source)
    "#tournament_tournament_payment_source_#{source.to_s}"
  end

  def payment_source_fields_css(source)
    "#payment_source_fields_#{source.to_s}"
  end
end
