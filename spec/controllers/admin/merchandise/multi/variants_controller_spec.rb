require  'spec_helper'

describe Admin::Merchandise::Multi::VariantsController do
  render_views
  before(:each) do
    activate_authlogic
    @user = create_admin_user
    login_as(@user)
  end

  it "edit action should render edit template" do
    @product = create(:product)
    get :edit, :product_id => @product.id
    response.should render_template(:edit)
  end

  it "update action should render edit template when model is invalid" do
    @product = create(:product)
    Product.any_instance.stubs(:valid?).returns(false)
    put :update, :product_id => @product.id, :product => {:variants_attributes => {'0'=>[ :product_id => '1', :sku => '432', :name => 'testname', :price => '16.75', :cost => '16.00', :master => true, :brand_id => 1]} }
    response.should render_template(:edit)
  end

  it "update action should redirect when model is valid" do
    @product = create(:product)
    Product.any_instance.stubs(:valid?).returns(true)
    Variant.any_instance.stubs(:valid?).returns(true)
    put :update, :product_id => @product.id, :product => {:variants_attributes => {'0'=>[ :product_id => '1', :sku => '432', :name => 'testname', :price => '16.75', :cost => '16.00', :master => true, :brand_id => 1]} }
    response.should redirect_to(admin_merchandise_product_url(@product))
  end
end
