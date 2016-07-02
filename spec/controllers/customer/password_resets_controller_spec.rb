require  'spec_helper'

describe Customer::PasswordResetsController do
  render_views

  it "new action should render new template" do
    @user = FactoryGirl.create(:user)
    get :new
    expect(response).to render_template(:new)
  end

  it "create action should render new template when model is invalid" do
    User.any_instance.stubs(:valid?).returns(false)
    User.any_instance.stubs(:find_by_email).returns(nil)
    post :create, params: { user: { email: 'wertyuvc' }}
    expect(response).to render_template(:new)
  end

  it "create action should redirect when model is valid" do
    @user = FactoryGirl.create(:user)
    User.any_instance.stubs(:valid?).returns(true)
    User.any_instance.stubs(:find_by_email).returns(@user)
    post :create, params: { user: { email: @user.email }}
    #expect(response).to render_template('/customer/password_resets/confirmation')
  end

  it "edit action should render edit template" do
    @user = FactoryGirl.create(:user)
    get :edit, params: { id: @user.perishable_token}
    expect(response).to render_template(:edit)
  end

  it "edit action should render edit template" do
    @user = FactoryGirl.create(:user)
    get :edit, params: { id: 0 }
    expect(response).not_to render_template(:edit)
  end

  it "update action should render edit template when model is invalid" do
    @user = FactoryGirl.create(:user)
    User.any_instance.stubs(:valid?).returns(false)
    put :update, params: { id: @user.perishable_token, user: { password: 'testPWD123', password_confirmation: 'testPWD123'}}
    expect(response).to render_template(:edit)
  end

  it "update action should redirect when model is valid" do
    @user = FactoryGirl.create(:user)
    User.any_instance.stubs(:valid?).returns(true)
    put :update, params: { id: @user.perishable_token, user: { password: 'testPWD123', password_confirmation: 'testPWD123'}}
    expect(response).to redirect_to(login_url)
  end

end
