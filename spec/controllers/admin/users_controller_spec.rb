require  'spec_helper'

describe Admin::UsersController do
  # fixtures :all
  render_views
  before(:each) do
    activate_authlogic
    @customer = FactoryGirl.build(:user)
    @user = create_admin_user
    login_as(@user)
    @controller.stubs(:authorize!)
  end

  it "index action should render index template" do
    get :index
    expect(response).to render_template(:index)
  end

  it "show action should render show template" do
    @customer.save
    get :show, params: { id: @customer.id }
    expect(response).to render_template(:show)
  end

  it "new action should render new template" do
    get :new
    expect(response).to render_template(:new)
  end

  it "create action should render new template when model is invalid" do
    User.any_instance.stubs(:valid?).returns(false)
    post :create, params: {user: @customer.attributes.reject {|k,v| ![ 'first_name', 'last_name', 'password'].include?(k)}}
    expect(response).to render_template(:new)
  end

  it "create action should redirect when model is valid" do
    User.any_instance.stubs(:valid?).returns(true)
    post :create, params: {user: @customer.attributes.reject {|k,v| ![ 'first_name', 'last_name', 'password'].include?(k)}}
    expect(response).to redirect_to(admin_users_url())
  end

end
