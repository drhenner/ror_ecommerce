require  'spec_helper'

describe Admin::Inventory::OverviewsController do
  render_views

  before(:each) do
    activate_authlogic

    @user = create(:admin_user)
    login_as(@user)
    @product = create(:product)
  end

  it "index action should render index template" do
    get :index
    response.should render_template(:index)
  end

  it "edit action should render edit template" do
    get :edit, :id => @product.id
    response.should render_template(:edit)
  end

  it "update action should render edit template when model is invalid" do
    Product.any_instance.stubs(:valid?).returns(false)
    put :update, :id => @product.id
    response.should render_template(:edit)
  end

  it "update action should redirect when model is valid" do
    Product.any_instance.stubs(:valid?).returns(true)
    put :update, :id => @product.id
    response.should redirect_to(admin_inventory_overviews_url())
  end
end
