require  'spec_helper'

describe Admin::Config::TaxRatesController do
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

  it "show action should render show template" do
    @tax_rate = create(:tax_rate)
    get :show, :id => @tax_rate.id
    response.should render_template(:show)
  end

  it "new action should render new template" do
    get :new
    response.should render_template(:new)
  end

  it "create action should render new template when model is invalid" do
    TaxRate.any_instance.stubs(:valid?).returns(false)
    post :create
    response.should render_template(:new)
  end

  it "create action should redirect when model is valid" do
    TaxRate.any_instance.stubs(:valid?).returns(true)
    post :create, :tax_rate => { :start_date => Time.now.to_s(:db), :state_id => 1, :tax_category_id => 1}
    response.should redirect_to(admin_config_tax_rate_url(assigns[:tax_rate]))
  end

  it "edit action should render edit template" do
    @tax_rate = create(:tax_rate)
    get :edit, :id => @tax_rate.id
    response.should render_template(:edit)
  end

  it "update action should render edit template when model is invalid" do
    @tax_rate = create(:tax_rate)
    TaxRate.any_instance.stubs(:valid?).returns(false)
    put :update, :id => @tax_rate.id
    response.should render_template(:edit)
  end

  it "update action should redirect when model is valid" do
    @tax_rate = create(:tax_rate)
    TaxRate.any_instance.stubs(:valid?).returns(true)
    put :update, :id => @tax_rate.id
    response.should redirect_to(admin_config_tax_rate_url(assigns[:tax_rate]))
  end

  it "destroy action should destroy model and redirect to index action" do
    @tax_rate = create(:tax_rate)
    delete :destroy, :id => @tax_rate.id
    response.should redirect_to(admin_config_tax_rates_url)
    TaxRate.find(@tax_rate.id).active.should be_false
  end
end