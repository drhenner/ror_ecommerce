require  'spec_helper'

describe Admin::Merchandise::Multi::VariantsController do
  render_views
  before(:each) do
    activate_authlogic
    @user = Factory(:admin_user)
    login_as(@user)
  end

  it "edit action should render edit template" do
    @product = Factory(:product)
    get :edit, :product_id => @product.id
    response.should render_template(:edit)
  end

  it "update action should render edit template when model is invalid" do
    @product = Factory(:product)
    Product.any_instance.stubs(:valid?).returns(false)
    put :update, :product_id => @product.id
    response.should render_template(:edit)
  end

  it "update action should redirect when model is valid" do
    @product = Factory(:product)
    Product.any_instance.stubs(:valid?).returns(true)
    Variant.any_instance.stubs(:valid?).returns(true)
    put :update, :product_id => @product.id
    response.should redirect_to(admin_merchandise_product_url(@product))
  end
end
