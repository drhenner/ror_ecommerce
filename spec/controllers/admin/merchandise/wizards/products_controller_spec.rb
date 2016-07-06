require  'spec_helper'

describe Admin::Merchandise::Wizards::ProductsController do
  render_views

  before(:each) do
    activate_authlogic

    @user = create_admin_user
    login_as(@user)
    @property = FactoryGirl.create(:property)
    controller.session[:product_wizard]                        = {}
    controller.session[:product_wizard][:brand_id]             = 7# @brand.id
    controller.session[:product_wizard][:product_type_id]      = 7# @brand.id
    controller.session[:product_wizard][:property_ids]         = [@property.id]
    controller.session[:product_wizard][:shipping_category_id] = 3
  end

  it "new action should render new template" do
    get :new
    expect(response).to render_template(:new)
  end

  it "create action should render new template when model is invalid" do
    Product.any_instance.stubs(:valid?).returns(false)
    post :create, params: { product: { name: 'hello'} }
    expect(response).to render_template(:new)
  end

  it "create action should redirect when model is valid" do
    Product.any_instance.stubs(:valid?).returns(true)
    post :create, params: { product: { :name => 'hello',
                                       :permalink => 'hi',
                                       :product_type_id => 2,
                                       :shipping_category_id => 4
                                     }}
    expect(response).to redirect_to(edit_admin_merchandise_products_description_url(assigns[:product]))
  end
end
