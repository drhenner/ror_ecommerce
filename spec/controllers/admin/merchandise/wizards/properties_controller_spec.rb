require  'spec_helper'

describe Admin::Merchandise::Wizards::PropertiesController do
  render_views

  before(:each) do
    activate_authlogic

    @user = create_admin_user
    login_as(@user)
    controller.session[:product_wizard] = {}
    controller.session[:product_wizard][:brand_id] = 7# @brand.id
    controller.session[:product_wizard][:product_type_id] = 7# @brand.id
  end

  it "index action should render index template" do
    get :index
    expect(response).to render_template(:index)
  end

  it "create action should render new template when model is invalid" do
    Property.any_instance.stubs(:valid?).returns(false)
    post :create, params: { property: { identifing_name: 'test', display_name: 'test'} }
    expect(response).to render_template(:index)
  end

  it "create action should redirect when model is valid" do
    Property.any_instance.stubs(:valid?).returns(true)
    post :create, params: { property: { identifing_name: 'test', display_name: 'test'} }
    expect(response).to render_template(:index)
  end

  it "update action should render edit template when model is invalid" do
    @property = FactoryGirl.create(:property)
    put :update, params: { id: @property.id, property: {:ids => [ ]} }
    expect(response).to render_template(:index)
  end

  it "update action should redirect when model is valid" do
    @property = FactoryGirl.create(:property)
    put :update, params: { id: @property.id, property: { ids: [ @property.id ]} }
    expect(controller.session[:product_wizard][:property_ids]).to eq [@property.id]
    expect(response).to redirect_to(admin_merchandise_wizards_shipping_categories_url)
  end
end
