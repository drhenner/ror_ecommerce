require 'spec_helper'

describe Admin::HelpController do

  before(:each) do
    activate_authlogic
    @user = create(:admin_user)
    login_as(@user)
    @order = create(:order)
  end

  describe "GET 'index'" do
    it "returns http success" do
      get 'index'
      response.should be_success
    end
  end

end
