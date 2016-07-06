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
    get :show, params: { user_id: @user.id }
    expect(response).to render_template(:show)
  end

  it "edit action should render edit template" do
    get :edit, params: { user_id: @user.id }
    expect(response).to render_template(:edit)
  end

  it "update action should render edit template when model is invalid" do
    put :update, params: { user_id: @user.id, amount_to_add: 'ABC' }
    expect(response).to render_template(:edit)
  end

  it "update action should redirect when model is valid" do
    StoreCredit.any_instance.stubs(:valid?).returns(true)
    put :update, params: { user_id: @user.id, amount_to_add: '20.0'}
    expect(response).to redirect_to(admin_user_datas_user_store_credits_url(@user))
  end
  it "update action should redirect when model is valid" do
    StoreCredit.any_instance.stubs(:valid?).returns(true)
    put :update, params: { user_id: @user.id, amount_to_add: '-20.00' }
    expect(response).to redirect_to(admin_user_datas_user_store_credits_url(@user))
  end
end
