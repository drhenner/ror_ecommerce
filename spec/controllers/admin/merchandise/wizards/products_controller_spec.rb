require  'spec_helper'

describe Admin::Merchandise::Wizards::ProductsController do
  render_views

  before(:each) do
    activate_authlogic

    @user = create(:admin_user)
    login_as(@user)
    @property = create(:property)
    controller.session[:product_wizard] = {}
    controller.session[:product_wizard][:brand_id] = 7# @brand.id
    controller.session[:product_wizard][:product_type_id] = 7# @brand.id
    controller.session[:product_wizard][:property_ids]    = [@property.id]
    controller.session[:product_wizard][:tax_category_id]   = 9
    controller.session[:product_wizard][:shipping_category_id] = 3
  end

  it "new action should render new template" do
    get :new
    response.should render_template(:new)
  end

  it "create action should render new template when model is invalid" do
    Product.any_instance.stubs(:valid?).returns(false)
    post :create, :product => { :name => 'hello'}
    response.should render_template(:new)
  end

  it "create action should redirect when model is valid" do
    Product.any_instance.stubs(:valid?).returns(true)
    post :create, :product => { :name => 'hello',
                                :permalink => 'hi',
                                :product_type_id => 2,
                                :shipping_category_id => 4,
                                :tax_category_id =>6}
    response.should redirect_to(edit_admin_merchandise_products_description_url(assigns[:product]))
  end
end
