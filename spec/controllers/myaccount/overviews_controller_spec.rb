require  'spec_helper'

describe Myaccount::OverviewsController do
  render_views

  before(:each) do
    activate_authlogic

    @user = FactoryGirl.create(:user)
    login_as(@user)
  end

  it "show action should render show template" do
    get :show
    expect(response).to render_template(:show)
  end

  it "show action should render show template" do
    @address = FactoryGirl.create(:address, :addressable => @user)
    @user.stubs(:shipping_address).returns(@address)
    get :show
    expect(response).to render_template(:show)
  end

  it "edit action should render edit template" do
    get :edit
    expect(response).to render_template(:edit)
  end

  it "update action should render edit template when model is invalid" do
    User.any_instance.stubs(:valid?).returns(false)
    put :update, params: {user: @user.attributes.reject {|k,v| ![ 'first_name', 'last_name', 'password'].include?(k)}}
    expect(response).to render_template(:edit)
  end

  it "update action should redirect when model is valid" do
    User.any_instance.stubs(:valid?).returns(true)
    put :update, params: {user: @user.attributes.reject {|k,v| ![ 'first_name', 'last_name', 'password'].include?(k)}}
    expect(response).to redirect_to(myaccount_overview_url())
  end
end

describe Myaccount::OverviewsController do
  render_views

  it "not logged in should redirect to login page" do
    get :show
    expect(response).to redirect_to(login_url)
  end
end
