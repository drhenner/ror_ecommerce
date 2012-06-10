require  'spec_helper'

describe Customer::PasswordResetsController do
  render_views

  it "new action should render new template" do
    @user = create(:user)
    get :new
    response.should render_template(:new)
  end

  it "create action should render new template when model is invalid" do
    User.any_instance.stubs(:valid?).returns(false)
    User.any_instance.stubs(:find_by_email).returns(nil)
    post :create, :user => {:email => 'wertyuvc'}
    response.should render_template(:new)
  end

  it "create action should redirect when model is valid" do
    @user = create(:user)
    User.any_instance.stubs(:valid?).returns(true)
    User.any_instance.stubs(:find_by_email).returns(@user)
    post :create, :user => {:email => @user.email}
    #response.should render_template('/customer/password_resets/confirmation')
  end

  it "edit action should render edit template" do
    @user = create(:user)
    get :edit, :id => @user.perishable_token
    response.should render_template(:edit)
  end

  it "update action should render edit template when model is invalid" do
    @user = create(:user)
    User.any_instance.stubs(:valid?).returns(false)
    put :update, :id => @user.perishable_token, :user => {:password => 'testPWD123', :password_confirmation => 'testPWD123'}
    response.should render_template(:edit)
  end

  it "update action should redirect when model is valid" do
    @user = create(:user)
    User.any_instance.stubs(:valid?).returns(true)
    put :update, :id => @user.perishable_token, :user => {:password => 'testPWD123', :password_confirmation => 'testPWD123'}
    response.should redirect_to(login_url)
  end

end