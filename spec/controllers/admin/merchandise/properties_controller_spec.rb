require  'spec_helper'

describe Admin::Merchandise::PropertiesController do
  render_views

  before(:each) do
    activate_authlogic

    @user = create_admin_user
    login_as(@user)

    controller.stubs(:current_ability).returns(Ability.new(@user))
  end

  it "index action should render index template" do
    @property = FactoryGirl.create(:property)
    get :index
    expect(response).to render_template(:index)
  end

  it "new action should render new template" do
    get :new
    expect(response).to render_template(:new)
  end

  it "create action should render new template when model is invalid" do
    Property.any_instance.stubs(:valid?).returns(false)
    post :create, params: { property: { display_name: 'dis', identifing_name: 'test'} }
    expect(response).to render_template(:new)
  end

  it "create action should redirect when model is valid" do
    Property.any_instance.stubs(:valid?).returns(true)
    post :create, params: { property: { display_name: 'dis', identifing_name: 'test'} }
    expect(response).to redirect_to(admin_merchandise_properties_url)
  end

  it "edit action should render edit template" do
    @property = FactoryGirl.create(:property)
    get :edit, params: { id: @property.id }
    expect(response).to render_template(:edit)
  end

  it "update action should render edit template when model is invalid" do
    @property = FactoryGirl.create(:property)
    Property.any_instance.stubs(:valid?).returns(false)
    put :update, params: { id: @property.id, property: {:display_name => 'dis', :identifing_name => 'test'} }
    expect(response).to render_template(:edit)
  end

  it "update action should redirect when model is valid" do
    @property = FactoryGirl.create(:property)
    Property.any_instance.stubs(:valid?).returns(true)
    put :update, params: { :id => @property.id, :property => {:display_name => 'dis', :identifing_name => 'test'} }
    expect(response).to redirect_to(admin_merchandise_properties_url)
  end

  it "destroy action should destroy model and redirect to index action" do
    @property = FactoryGirl.create(:property)
    delete :destroy, params: { :id => @property.id }
    expect(response).to redirect_to(admin_merchandise_properties_url)
    expect(Property.find(@property.id).active).to eq false
  end
end
