require  'spec_helper'

describe Myaccount::StoreCreditsController do
  render_views


  before(:each) do
    activate_authlogic

    @user = FactoryGirl.create(:user)
    login_as(@user)
  end

  it "show action should render show template" do
    @store_credit = FactoryGirl.create(:store_credit, user: @user)
    get :show, params: { id: @store_credit.id }
    expect(response).to render_template(:show)
  end
end
