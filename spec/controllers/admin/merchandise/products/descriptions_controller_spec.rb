require  'spec_helper'

describe Admin::Merchandise::Products::DescriptionsController do
  render_views

  before(:each) do
    activate_authlogic

    @user = create(:admin_user)
    login_as(@user)
  end

  it "edit action should render edit template" do
    @product = create(:product, :active => false, :description_markup => nil, :description => nil)
    get :edit, :id => @product.id
    response.should render_template(:edit)
  end

  it "update action should render edit template when model is invalid" do
    @product = create(:product)
    Product.any_instance.stubs(:valid?).returns(false)
    put :update, :id => @product.id
    response.should render_template(:edit)
  end

  it "update action should redirect when model is valid" do
    @product = create(:product, :active => false, :description_markup => nil, :description => nil)
    Product.any_instance.stubs(:valid?).returns(true)
    put :update, :id => @product.id, :product => {:description_markup => '**Hi Everybody**'}
    @product.reload
    @product.description.should_not be_nil
    response.should redirect_to(admin_merchandise_product_url(@product))
  end
end
