require  'spec_helper'

describe Myaccount::StoreCreditsController do
  render_views


  before(:each) do
    activate_authlogic

    @user = create(:user)
    login_as(@user)
  end

  it "show action should render show template" do
    @store_credit = create(:store_credit, :user => @user)
    get :show, :id => @store_credit.id
    response.should render_template(:show)
  end
end
