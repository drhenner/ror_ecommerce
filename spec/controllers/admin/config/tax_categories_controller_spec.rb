require  'spec_helper'

describe Admin::Config::TaxCategoriesController do
  render_views

  before(:each) do
    activate_authlogic

    @user = create(:admin_user)
    login_as(@user)
  end

  it "index action should render index template" do
    get :index
    response.should render_template(:index)
  end

  #it "show action should render show template" do
  #  @tax_category = TaxCategory.first
  #  get :show, :id => @tax_category.id
  #  response.should render_template(:show)
  #end

  it "new action should render new template" do
    get :new
    response.should render_template(:new)
  end

  it "create action should render new template when model is invalid" do
    TaxCategory.any_instance.stubs(:valid?).returns(false)
    post :create
    response.should render_template(:new)
  end

  it "create action should redirect when model is valid" do
    TaxCategory.any_instance.stubs(:valid?).returns(true)
    post :create, :tax_category => {:name => 'Jewels'}
    response.should redirect_to(admin_config_tax_categories_url())
  end

  it "edit action should render edit template" do
    @tax_category = TaxCategory.first
    get :edit, :id => @tax_category.id
    response.should render_template(:edit)
  end

  it "update action should render edit template when model is invalid" do
    @tax_category = TaxCategory.first
    TaxCategory.any_instance.stubs(:valid?).returns(false)
    put :update, :id => @tax_category.id
    response.should render_template(:edit)
  end

  it "update action should redirect when model is valid" do
    @tax_category = TaxCategory.first
    TaxCategory.any_instance.stubs(:valid?).returns(true)
    put :update, :id => @tax_category.id
    response.should redirect_to(admin_config_tax_categories_url())
  end

  it "destroy action should destroy model and redirect to index action" do
    @tax_category = TaxCategory.create(:name => 'Jewels')
    delete :destroy, :id => @tax_category.id
    response.should redirect_to(admin_config_tax_categories_url)
    TaxCategory.exists?(@tax_category.id).should be_false
  end
end