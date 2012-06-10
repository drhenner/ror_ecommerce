require  'spec_helper'

describe Admin::Merchandise::VariantsController do
  render_views

  before(:each) do
    activate_authlogic

    @user = create(:admin_user)
    login_as(@user)
    @product = create(:product)
  end

  it "index action should render index template" do
    @variant = create(:variant, :product => @product)
    get :index, :product_id => @product.id
    response.should render_template(:index)
  end

  it "show action should render show template" do
    @variant = create(:variant, :product => @product)
    get :show, :id => @variant.id, :product_id => @product.id
    response.should render_template(:show)
  end

  it "new action should render new template" do
    get :new, :product_id => @product.id
    response.should render_template(:new)
  end

  it "create action should render new template when model is invalid" do
    Variant.any_instance.stubs(:valid?).returns(false)
    post :create, :product_id => @product.id
    response.should render_template(:new)
  end

  it "create action should redirect when model is valid" do
    @variant = build(:variant, :product => @product)
    Variant.any_instance.stubs(:valid?).returns(true)
    post :create, :product_id => @product.id, :variant => @variant.attributes
    response.should redirect_to(admin_merchandise_product_variants_url(@product))
  end

  it "edit action should render edit template" do
    @variant = create(:variant, :product => @product)
    get :edit, :id => @variant.id, :product_id => @product.id
    response.should render_template(:edit)
  end

  it "update action should render edit template when model is invalid" do
    @variant = create(:variant, :product => @product)
    Variant.any_instance.stubs(:valid?).returns(false)
    put :update, :id => @variant.id, :product_id => @product.id
    response.should render_template(:edit)
  end

  it "update action should redirect when model is valid" do
    @variant = create(:variant, :product => @product)
    Variant.any_instance.stubs(:valid?).returns(true)
    put :update, :id => @variant.id, :product_id => @product.id
    response.should redirect_to(admin_merchandise_product_variants_url(@variant.product))
  end

  it "destroy action should destroy model and redirect to index action" do
    @variant = create(:variant, :product => @product)
    delete :destroy, :id => @variant.id, :product_id => @product.id
    response.should redirect_to(admin_merchandise_product_variants_url(@product))
    Variant.find(@variant.id).deleted_at.should_not be_nil
  end
end
