require  'spec_helper'

describe Admin::UserDatas::StoreCreditsController do
  # fixtures :all
  render_views
  before(:each) do
    activate_authlogic
    @cur_user = FactoryGirl.create(:admin_user)
    login_as(@cur_user)
    @user = FactoryGirl.create(:user)
  end

  it "show action should render show template" do
    get :show, :user_id => @user.id
    response.should render_template(:show)
  end

  it "edit action should render edit template" do
    get :edit, :user_id => @user.id
    response.should render_template(:edit)
  end

  it "update action should render edit template when model is invalid" do
    put :update, :user_id => @user.id, :amount_to_add => 'ABC'
    response.should render_template(:edit)
  end

  it "update action should redirect when model is valid" do
    StoreCredit.any_instance.stubs(:valid?).returns(true)
    put :update, :user_id => @user.id, :amount_to_add => '20.0'
    response.should redirect_to(admin_user_datas_user_store_credits_url(@user))
  end
  it "update action should redirect when model is valid" do
    StoreCredit.any_instance.stubs(:valid?).returns(true)
    put :update, :user_id => @user.id, :amount_to_add => '-20.00'
    response.should redirect_to(admin_user_datas_user_store_credits_url(@user))
  end
end
