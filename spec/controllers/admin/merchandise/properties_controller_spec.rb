require  'spec_helper'

describe Admin::Merchandise::PropertiesController do
  render_views

  before(:each) do
    activate_authlogic

    @user = create(:admin_user)
    login_as(@user)

    controller.stubs(:current_ability).returns(Ability.new(@user))
  end

  it "index action should render index template" do
    @property = create(:property)
    get :index
    response.should render_template(:index)
  end

  it "new action should render new template" do
    get :new
    response.should render_template(:new)
  end

  it "create action should render new template when model is invalid" do
    Property.any_instance.stubs(:valid?).returns(false)
    post :create
    response.should render_template(:new)
  end

  it "create action should redirect when model is valid" do
    Property.any_instance.stubs(:valid?).returns(true)
    post :create, :property => {:display_name => 'dis', :identifing_name => 'test'}
    response.should redirect_to(admin_merchandise_properties_url)
  end

  it "edit action should render edit template" do
    @property = create(:property)
    get :edit, :id => @property.id
    response.should render_template(:edit)
  end

  it "update action should render edit template when model is invalid" do
    @property = create(:property)
    Property.any_instance.stubs(:valid?).returns(false)
    put :update, :id => @property.id
    response.should render_template(:edit)
  end

  it "update action should redirect when model is valid" do
    @property = create(:property)
    Property.any_instance.stubs(:valid?).returns(true)
    put :update, :id => @property.id
    response.should redirect_to(admin_merchandise_properties_url)
  end

  it "destroy action should destroy model and redirect to index action" do
    @property = create(:property)
    delete :destroy, :id => @property.id
    response.should redirect_to(admin_merchandise_properties_url)
    Property.find(@property.id).active.should be_false
  end
end
