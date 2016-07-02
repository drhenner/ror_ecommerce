require  'spec_helper'

describe Admin::Merchandise::ProductsController do
  render_views

  before(:each) do
    activate_authlogic

    @user = create_admin_user
    login_as(@user)

    controller.stubs(:current_ability).returns(Ability.new(@user))
  end

  it "index action should render index template" do
    @product = FactoryGirl.create(:product)
    get :index
    expect(response).to render_template(:index)
  end

  it "show action should render show template" do
    @product = FactoryGirl.create(:product)
    get :show, params: { id: @product.id }
    expect(response).to render_template(:show)
  end

  it "new action should render new template" do
    Prototype.stubs(:all).returns([])
    get :new
    expect(response).to redirect_to(new_admin_merchandise_prototype_url)
  end

  it "new action should render new template" do
    @prototype = FactoryGirl.create(:prototype)
    get :new
    expect(response).to render_template(:new)
  end

  it "create action should render new template when model is invalid" do
    Product.any_instance.stubs(:valid?).returns(false)
    post :create, params: { product: product_attributes }
    expect(response).to render_template(:new)
  end

  it "create action should redirect when model is valid" do
    @product = build(:product, :description_markup => nil, :deleted_at => (Time.zone.now - 1.day))
    Product.any_instance.stubs(:valid?).returns(true)
    post :create, params: { product: @product.attributes }
    expect(response).to redirect_to(edit_admin_merchandise_products_description_url(assigns[:product]))
  end

  it "edit action should render edit template" do
    @product = FactoryGirl.create(:product)
    get :edit, params: {id: @product.id}
    expect(response).to render_template(:edit)
  end

  it "update action should render edit template when model is invalid" do
    @product = FactoryGirl.create(:product)
    Product.any_instance.stubs(:valid?).returns(false)
    put :update, params: { id: @product.id, :product => product_attributes }
    expect(response).to render_template(:edit)
  end

  it "update action should redirect when model is valid" do
    @product = FactoryGirl.create(:product)
    Product.any_instance.stubs(:valid?).returns(true)
    put :update, params: { id: @product.id, :product => product_attributes }
    expect(response).to redirect_to(admin_merchandise_product_url(assigns[:product]))
  end

  it "activate action should redirect when model is valid" do
    Product.any_instance.stubs(:ensure_available).returns(true)
    @product = FactoryGirl.create(:product, :deleted_at => (Time.zone.now - 1.day))
    put :activate, params: { id: @product.id, :product => product_attributes }
    @product.reload
    expect(@product.active).to be true
    expect(response).to redirect_to(admin_merchandise_product_url(assigns[:product]))
  end
  it "activate action should redirect to create description when model is valid" do
    @product = FactoryGirl.create(:product, :description_markup => nil, :deleted_at => (Time.zone.now - 1.day))
    put :activate, params: { id: @product.id, :product => product_attributes }
    @product.reload
    expect(@product.active).to be false
    expect(response).to redirect_to(edit_admin_merchandise_products_description_url(assigns[:product]))
  end

  it "destroy action should destroy model and redirect to index action" do
    @product = FactoryGirl.create(:product)
    delete :destroy, params: { id: @product.id }
    expect(response).to redirect_to(admin_merchandise_product_url(@product))
    expect(Product.find(@product.id).active).to eq false
  end
  def product_attributes
    {:name => 'cute pants', :set_keywords => 'test,one,two,three', :product_type_id => 1, :prototype_id => nil, :shipping_category_id => 1, :permalink => 'linkToMe', :available_at => Time.zone.now, :deleted_at => nil, :meta_keywords => 'cute,pants,bacon', :meta_description => 'good pants', :featured => true, :brand_id => 1}
  end
end
