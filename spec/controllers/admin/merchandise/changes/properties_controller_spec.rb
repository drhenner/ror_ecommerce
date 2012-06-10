require  'spec_helper'

describe Admin::Merchandise::Changes::PropertiesController do
  render_views

  before(:each) do
    activate_authlogic

    @user = create(:admin_user)
    login_as(@user)
    controller.session[:product_wizard] = {}
  end

  it "edit action should render edit template" do
    @product = create(:product)
    get :edit, :product_id => @product.id
    response.should render_template(:edit)
  end

  it "update action should render edit template when model is invalid" do
    @product = create(:product)
    Product.any_instance.stubs(:valid?).returns(false)
    put :update, :product_id => @product.id
    response.should render_template(:edit)
  end

  it "update action should redirect when model is valid" do
    @product = create(:product)
    Product.any_instance.stubs(:valid?).returns(true)
    put :update, :product_id => @product.id
    response.should redirect_to(admin_merchandise_product_url(@product.id))
  end
end
