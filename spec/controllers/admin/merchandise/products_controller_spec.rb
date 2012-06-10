require  'spec_helper'

describe Admin::Merchandise::ProductsController do
  render_views

  before(:each) do
    activate_authlogic

    @user = create(:admin_user)
    login_as(@user)

    controller.stubs(:current_ability).returns(Ability.new(@user))
  end

  it "index action should render index template" do
    @product = create(:product)
    get :index
    response.should render_template(:index)
  end

  it "show action should render show template" do
    @product = create(:product)
    get :show, :id => @product.id
    response.should render_template(:show)
  end

  it "new action should render new template" do
    Prototype.stubs(:all).returns([])
    get :new
    response.should redirect_to(new_admin_merchandise_prototype_url)
  end

  it "new action should render new template" do
    @prototype = create(:prototype)
    get :new
    response.should render_template(:new)
  end

  it "create action should render new template when model is invalid" do
    Product.any_instance.stubs(:valid?).returns(false)
    post :create#, :product => @product.attributes
    response.should render_template(:new)
  end

  it "create action should redirect when model is valid" do
    @product = build(:product, :description_markup => nil, :active => false)
    Product.any_instance.stubs(:valid?).returns(true)
    post :create, :product => @product.attributes
    response.should redirect_to(edit_admin_merchandise_products_description_url(assigns[:product]))
  end

  it "edit action should render edit template" do
    @product = create(:product)
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
    @product = create(:product)
    Product.any_instance.stubs(:valid?).returns(true)
    put :update, :id => @product.id
    response.should redirect_to(admin_merchandise_product_url(assigns[:product]))
  end

  it "activate action should redirect when model is valid" do
    @product = create(:product, :active => false)
    put :activate, :id => @product.id
    @product.reload
    @product.active.should be_true
    response.should redirect_to(admin_merchandise_product_url(assigns[:product]))
  end
  it "activate action should redirect to create description when model is valid" do
    @product = create(:product, :active => false, :description_markup => nil)
    put :activate, :id => @product.id
    @product.reload
    @product.active.should be_false
    response.should redirect_to(edit_admin_merchandise_products_description_url(assigns[:product]))
  end

  it "destroy action should destroy model and redirect to index action" do
    @product = create(:product)
    delete :destroy, :id => @product.id
    response.should redirect_to(admin_merchandise_product_url(@product))
    Product.find(@product.id).active.should be_false
  end
end
