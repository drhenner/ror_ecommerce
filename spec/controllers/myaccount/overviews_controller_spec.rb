require  'spec_helper'

describe Myaccount::OverviewsController do
  render_views

  before(:each) do
    activate_authlogic

    @user = Factory(:user)
    login_as(@user)
  end

  it "show action should render show template" do
    get :show
    response.should render_template(:show)
  end
end

describe Myaccount::OverviewsController do
  render_views

  it "not logged in should redirect to login page" do
    get :show
    response.should redirect_to(login_url)
  end
end
