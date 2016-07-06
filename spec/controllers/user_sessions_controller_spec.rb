require 'spec_helper'

describe UserSessionsController do
  describe "#create" do
    context "when login fails" do
      it "should display a message with login failure and render the login template" do
        post :create, params: { :user_session => {:email => 'test@test.com'} }
        expect(flash[:alert]).to eq I18n.t('login_failure')
        expect(response).to redirect_to login_url
      end
    end
  end

  describe "#destroy" do
    let(:user)         { FactoryGirl.create(:user) }
    let(:user_session) { UserSession.create email: user.email, password: 'password' }

    before do
      subject.stubs(:current_user_session).returns(user)
    end

    it "should display a message with logout success and render the login template" do
      post :destroy
      expect(flash[:notice]).to eq I18n.t('logout_successful')
      expect(response).to redirect_to login_url
    end
  end
end
