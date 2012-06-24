require  'spec_helper'

describe Admin::Merchandise::Wizards::ShippingCategoriesController do
  render_views

  before(:each) do
    activate_authlogic

    @user = create(:admin_user)
    login_as(@user)
    controller.session[:product_wizard] = {}
    controller.session[:product_wizard][:brand_id] = 7# @brand.id
    controller.session[:product_wizard][:product_type_id] = 7# @brand.id
    controller.session[:product_wizard][:property_ids]    = [1,2]
    controller.session[:product_wizard][:tax_category_id]   = 9
  end

  it "index action should render index template" do
    get :index
    response.should render_template(:index)
  end

  it "create action should render new template when model is invalid" do
    ShippingCategory.any_instance.stubs(:valid?).returns(false)
    post :create, :shipping_category =>{:name => 'test'}
    response.should render_template(:index)
  end

  it "create action should redirect when model is valid" do
    ShippingCategory.any_instance.stubs(:valid?).returns(true)
    post :create, :shipping_category =>{:name => 'test'}
    response.should redirect_to(new_admin_merchandise_wizards_product_url)
  end

  it "update action should render edit template when model is invalid" do
    @shipping_category = create(:shipping_category)
    ShippingCategory.stubs(:find_by_id).returns(nil)
    put :update, :id => @shipping_category.id
    response.should render_template(:index)
  end

  it "update action should redirect when model is valid" do
    @shipping_category = create(:shipping_category)
    #ShippingCategory.any_instance.stubs(:valid?).returns(true)
    put :update, :id => @shipping_category.id
    controller.session[:product_wizard][:shipping_category_id].should   == @shipping_category.id
    response.should redirect_to(new_admin_merchandise_wizards_product_url)
  end
end
