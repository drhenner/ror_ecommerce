require  'spec_helper'

describe Admin::Merchandise::VariantsController do
  render_views

  before(:each) do
    activate_authlogic

    @user = create_admin_user
    login_as(@user)
    @product = FactoryGirl.create(:product)
  end

  it "index action should render index template" do
    @variant = FactoryGirl.create(:variant, :product => @product)
    get :index, params: { product_id: @product.id }
    expect(response).to render_template(:index)
  end

  it "show action should render show template" do
    @variant = FactoryGirl.create(:variant, :product => @product)
    get :show, params: { id: @variant.id, product_id: @product.id }
    expect(response).to render_template(:show)
  end

  it "new action should render new template" do
    get :new, params: { product_id: @product.id }
    expect(response).to render_template(:new)
  end
#require(:variant).permit(:product_id, :sku, :name, :price, :cost, :deleted_at, :master, :brand_id, :inventory_id )
  it "create action should render new template when model is invalid" do
    Variant.any_instance.stubs(:valid?).returns(false)
    post :create, params: {:product_id => @product.id, :variant => {:sku => '1232-abc', :name => 'variant name', :price => '20.00', :cost => '10.00', :deleted_at => nil, :master => false, :brand_id => 1}}
    expect(response).to render_template(:new)
  end

  it "create action should redirect when model is valid" do
    Variant.any_instance.stubs(:valid?).returns(true)
    post :create, params: { product_id: @product.id, variant: {:sku => '1232-abc', :name => 'variant name', :price => '20.00', :cost => '10.00', :deleted_at => nil, :master => false, :brand_id => 1}}
    expect(response).to redirect_to(admin_merchandise_product_variants_url(@product))
  end

  it "edit action should render edit template" do
    @variant = FactoryGirl.create(:variant, product: @product)
    get :edit, params: { id: @variant.id, product_id: @product.id }
    expect(response).to render_template(:edit)
  end

  it "update action should render edit template when model is invalid" do
    @variant = FactoryGirl.create(:variant, product: @product)
    Variant.any_instance.stubs(:valid?).returns(false)
    put :update, params: {:id => @variant.id, :product_id => @product.id, :variant => {:sku => '1232-abc', :name => 'variant name', :price => '20.00', :cost => '10.00', :deleted_at => nil, :master => false, :brand_id => 1}}
    expect(response).to render_template(:edit)
  end

  it "update action should redirect when model is valid" do
    @variant = FactoryGirl.create(:variant, product: @product)
    Variant.any_instance.stubs(:valid?).returns(true)
    put :update, params: {:id => @variant.id, :product_id => @product.id, :variant => {:sku => '1232-abc', :name => 'variant name', :price => '20.00', :cost => '10.00', :deleted_at => nil, :master => false, :brand_id => 1}}
    expect(response).to redirect_to(admin_merchandise_product_variants_url(@variant.product))
  end

  it "destroy action should destroy model and redirect to index action" do
    @variant = FactoryGirl.create(:variant, product: @product)
    delete :destroy, params: { id: @variant.id, product_id: @product.id }
    expect(response).to redirect_to(admin_merchandise_product_variants_url(@product))
    expect(Variant.find(@variant.id).deleted_at).not_to be_nil
  end
end
