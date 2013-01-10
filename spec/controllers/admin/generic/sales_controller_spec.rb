require  'spec_helper'

describe Admin::Generic::SalesController do
  # fixtures :all
  render_views
  before(:each) do
    activate_authlogic
    @user = create_admin_user
    login_as(@user)
  end

  it "index action should render index template" do
    sale = FactoryGirl.create(:sale)
    get :index
    response.should render_template(:index)
  end

  it "show action should render show template" do
    sale = FactoryGirl.create(:sale)
    get :show, :id => sale.id
    response.should render_template(:show)
  end

  it "new action should render new template" do
    get :new
    response.should render_template(:new)
  end

  it "create action should render new template when model is invalid" do
    sale = FactoryGirl.build(:sale)
    Sale.any_instance.stubs(:valid?).returns(false)
    post :create, :sale => sale.attributes.except('id', 'created_at', 'updated_at')
    response.should render_template(:new)
  end

  it "create action should redirect when model is valid" do
    sale = FactoryGirl.build(:sale)
    Sale.any_instance.stubs(:valid?).returns(true)
    post :create, :sale => sale.attributes.except('id', 'created_at', 'updated_at')
    response.should redirect_to(admin_generic_sale_url(assigns[:sale]))
  end

  it "edit action should render edit template" do
    sale = FactoryGirl.create(:sale)
    get :edit, :id => sale.id
    response.should render_template(:edit)
  end

  it "update action should render edit template when model is invalid" do
    sale = FactoryGirl.create(:sale)
    Sale.any_instance.stubs(:valid?).returns(false)
    put :update, :id => sale.id, :sale => sale.attributes.except('id', 'created_at', 'updated_at')
    response.should render_template(:edit)
  end

  it "update action should redirect when model is valid" do
    sale = FactoryGirl.create(:sale)
    Sale.any_instance.stubs(:valid?).returns(true)
    put :update, :id => sale.id, :sale => sale.attributes.except('id', 'created_at', 'updated_at')
    response.should redirect_to(admin_generic_sale_url(assigns[:sale]))
  end

  it "destroy action should destroy model and redirect to index action" do
    sale = FactoryGirl.create(:sale)
    delete :destroy, :id => sale.id
    response.should redirect_to(admin_generic_sales_url)
    Sale.exists?(sale.id).should be_false
  end
end
