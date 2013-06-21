require 'spec_helper'

describe UserTournamentsController do

  describe '#edit' do
    it_behaves_like "requires_login" do
      before { get :edit, id: 2 }
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
    it_behaves_like "requires_login" do
      before { delete :destroy, id: 2 }
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

  describe '#prize_pool' do
    it_behaves_like "requires_login" do
      before { get :prize_pool, id: 2 }
    end
  end

end
