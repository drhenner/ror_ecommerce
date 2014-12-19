require 'spec_helper'

describe Admin::HelpController do

  before(:each) do
    activate_authlogic
    @user = create_admin_user
    login_as(@user)
    @order = create(:order)
  end

  describe "GET 'index'" do
    it "returns http success" do
      get 'index'
      expect(response).to be_success
    end
  end

end
