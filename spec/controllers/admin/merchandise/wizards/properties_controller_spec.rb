require  'spec_helper'

describe Admin::Merchandise::Wizards::PropertiesController do
  render_views

  before(:each) do
    activate_authlogic

    @user = create(:admin_user)
    login_as(@user)
    controller.session[:product_wizard] = {}
    controller.session[:product_wizard][:brand_id] = 7# @brand.id
    controller.session[:product_wizard][:product_type_id] = 7# @brand.id
  end

  it "index action should render index template" do
    get :index
    response.should render_template(:index)
  end

  it "create action should render new template when model is invalid" do
    Property.any_instance.stubs(:valid?).returns(false)
    post :create, :property => {:identifing_name => 'test', :display_name => 'test'}
    response.should render_template(:index)
  end

  it "create action should redirect when model is valid" do
    Property.any_instance.stubs(:valid?).returns(true)
    post :create, :property => {:identifing_name => 'test', :display_name => 'test'}
    response.should render_template(:index)
  end

  it "update action should render edit template when model is invalid" do
    @property = create(:property)
    put :update, :id => @property.id, :property => {:ids => [ ]}
    response.should render_template(:index)
  end

  it "update action should redirect when model is valid" do
    @property = create(:property)
    put :update, :id => @property.id, :property => {:ids => [ @property.id ]}
    controller.session[:product_wizard][:property_ids].should == [@property.id]
    response.should redirect_to(admin_merchandise_wizards_tax_categories_url)
  end
end
