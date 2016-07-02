require  'spec_helper'

describe Admin::Merchandise::Wizards::ShippingCategoriesController do
  render_views

  before(:each) do
    activate_authlogic

    @user = create_admin_user
    login_as(@user)
    controller.session[:product_wizard] = {}
    controller.session[:product_wizard][:brand_id] = 7# @brand.id
    controller.session[:product_wizard][:product_type_id] = 7# @brand.id
    controller.session[:product_wizard][:property_ids]    = [1,2]
  end

  it "index action should render index template" do
    get :index
    expect(response).to render_template(:index)
  end

  it "create action should render new template when model is invalid" do
    ShippingCategory.any_instance.stubs(:valid?).returns(false)
    post :create, params: { shipping_category: {name: 'test'} }
    expect(response).to render_template(:index)
  end

  it "create action should redirect when model is valid" do
    ShippingCategory.any_instance.stubs(:valid?).returns(true)
    post :create, params: { shipping_category: { name: 'test'} }
    expect(response).to redirect_to(new_admin_merchandise_wizards_product_url)
  end

  it "update action should render edit template when model is invalid" do
    @shipping_category = FactoryGirl.create(:shipping_category)
    ShippingCategory.stubs(:find_by_id).returns(nil)
    put :update, params: { id: @shipping_category.id }
    expect(response).to render_template(:index)
  end

  it "update action should redirect when model is valid" do
    @shipping_category = FactoryGirl.create(:shipping_category)
    put :update, params: { id: @shipping_category.id }
    expect(controller.session[:product_wizard][:shipping_category_id]).to eq @shipping_category.id
    expect(response).to redirect_to(new_admin_merchandise_wizards_product_url)
  end
end
