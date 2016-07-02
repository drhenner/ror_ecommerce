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
    expect(response).to render_template(:index)
  end

  it "show action should render show template" do
    sale = FactoryGirl.create(:sale)
    get :show, params: { :id => sale.id }
    expect(response).to render_template(:show)
  end

  it "new action should render new template" do
    get :new
    expect(response).to render_template(:new)
  end

  it "create action should render new template when model is invalid" do
    sale = FactoryGirl.build(:sale)
    Sale.any_instance.stubs(:valid?).returns(false)
    post :create, params: { :sale => sale.attributes.except('id', 'created_at', 'updated_at') }
    expect(response).to render_template(:new)
  end

  it "create action should redirect when model is valid" do
    sale = FactoryGirl.build(:sale)
    Sale.any_instance.stubs(:valid?).returns(true)
    post :create, params: { :sale => sale.attributes.except('id', 'created_at', 'updated_at') }
    expect(response).to redirect_to(admin_generic_sale_url(assigns[:sale]))
  end

  it "edit action should render edit template" do
    sale = FactoryGirl.create(:sale)
    get :edit, params: { :id => sale.id }
    expect(response).to render_template(:edit)
  end

  it "update action should render edit template when model is invalid" do
    sale = FactoryGirl.create(:sale)
    Sale.any_instance.stubs(:valid?).returns(false)
    put :update, params: { :id => sale.id, :sale => sale.attributes.except('id', 'created_at', 'updated_at') }
    expect(response).to render_template(:edit)
  end

  it "update action should redirect when model is valid" do
    sale = FactoryGirl.create(:sale)
    Sale.any_instance.stubs(:valid?).returns(true)
    put :update, params: { :id => sale.id, :sale => sale.attributes.except('id', 'created_at', 'updated_at') }
    expect(response).to redirect_to(admin_generic_sale_url(assigns[:sale]))
  end

  it "destroy action should destroy model and redirect to index action" do
    sale = FactoryGirl.create(:sale)
    delete :destroy, params: { :id => sale.id }
    expect(response).to redirect_to(admin_generic_sales_url)
    expect(Sale.exists?(sale.id)).to eq false
  end
end
