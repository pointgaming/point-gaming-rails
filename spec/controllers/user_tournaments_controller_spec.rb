require 'spec_helper'

describe UserTournamentsController do
  describe '#edit' do
    it 'redirects when the user is not logged in' do
      get :edit, id: 2
      expect(response.status).to redirect_to(new_user_session_path)
    end

    describe 'when logged in' do
      let(:user) { Fabricate(:user) }
      let(:tournament) { Fabricate(:tournament) }

      it "is forbidden when the user doesn't have permission to edit the tournament" do
        sign_in(:user, user)
        get :edit, id: tournament._id
        expect(response.status).to redirect_to(action: :index)
        expect(flash[:alert]).to be_present
      end

      it "is successful when the user has permission to edit the tournament" do
        sign_in(:user, tournament.owner)
        get :edit, id: tournament._id
        expect(response).to be_success
      end
    end
  end

  describe '#destroy' do
    it 'redirects when the user is not logged in' do
      delete :destroy, id: 2
      expect(response.status).to redirect_to(new_user_session_path)
    end

    describe 'when logged in' do
      let(:user) { Fabricate(:user) }
      let(:tournament) { Fabricate(:tournament) }

      it "is forbidden when the user doesn't have permission to destroy the tournament" do
        sign_in(:user, user)
        delete :destroy, id: tournament._id
        expect(response.status).to redirect_to(action: :index)
        expect(flash[:alert]).to be_present
      end

      it "is successful when the user has permission to edit the tournament" do
        sign_in(:user, tournament.owner)
        delete :destroy, id: tournament._id
        expect(response.status).to redirect_to(user_tournaments_path)
      end
    end
  end


end
