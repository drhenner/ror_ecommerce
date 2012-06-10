require  'spec_helper'

describe Admin::Config::TaxStatusesController do
  render_views

  before(:each) do
    activate_authlogic

    @user = FactoryGirl.create(:admin_user)
    login_as(@user)
  end

  it "index action should render index template" do
    get :index
    response.should render_template(:index)
  end

  it "show action should render show template" do
    @tax_status = TaxStatus.first
    get :show, :id => @tax_status.id
    response.should render_template(:show)
  end

  it "new action should render new template" do
    get :new
    response.should render_template(:new)
  end

  it "create action should render new template when model is invalid" do
    TaxStatus.any_instance.stubs(:valid?).returns(false)
    post :create
    response.should render_template(:new)
  end

  it "create action should redirect when model is valid" do
    TaxStatus.any_instance.stubs(:valid?).returns(true)
    post :create, :tax_status => {:name => 'Jewels'}
    response.should redirect_to(admin_config_tax_statuses_url())
  end

  it "edit action should render edit template" do
    @tax_status = TaxStatus.first
    get :edit, :id => @tax_status.id
    response.should render_template(:edit)
  end

  it "update action should render edit template when model is invalid" do
    @tax_status = TaxStatus.first
    TaxStatus.any_instance.stubs(:valid?).returns(false)
    put :update, :id => @tax_status.id
    response.should render_template(:edit)
  end

  it "update action should redirect when model is valid" do
    @tax_status = TaxStatus.first
    TaxStatus.any_instance.stubs(:valid?).returns(true)
    put :update, :id => @tax_status.id
    response.should redirect_to(admin_config_tax_statuses_url())
  end

  it "destroy action should destroy model and redirect to index action" do
    @tax_status = TaxStatus.create(:name => 'Jewels')
    delete :destroy, :id => @tax_status.id
    response.should redirect_to(admin_config_tax_statuses_url)
    TaxStatus.exists?(@tax_status.id).should be_false
  end
end